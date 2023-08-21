//
//  RemoteChessServer.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/15.
//

import Foundation
import Combine

class RemoteChessServer: ChessServer {
    var cancellables = Set<AnyCancellable>()
    @Published private var roomToken: String? = UserDefaults.standard.roomToken
    @Published var roomId: String

    private let moveResultBoardStatePublisher = PassthroughSubject<BoardStateData, Error>()

    private lazy var payloadToBoardStateData: AnyPublisher<BoardStateData, Error> = {
        print("Lazy var created!")
        let notificationPayloads = NotificationManager.shared.getOrCreateSubject(for: roomId)
            .tryCompactMap { $0 }

        let merged = Publishers.Merge(
            notificationPayloads,
            moveResultBoardStatePublisher
        ).eraseToAnyPublisher()
        let compactJoinRoomResult = JoinRoomResultManager.shared.joinRoomResultBoardState
            .tryCompactMap {
            return $0
        }
        return merged.merge(with: compactJoinRoomResult)
            .print("Sth came")
            .eraseToAnyPublisher()
    }()

    init(roomId: String) {
        self.roomId = roomId
        let boardStateAndMoves = payloadToBoardStateData
            .map { boardStateData -> BoardStateAndMoves in
            let boardState = FenParser(fenStr: boardStateData.board, fowMark: "U").parse()
            let color: ChessColor
            if boardStateData.color == "white" {
                color = .white
            } else if boardStateData.color == "black" {
                color = .black
            } else {
                color = .white
            }
            return BoardStateAndMoves(boardState: boardState, legalMoves: boardStateData.legalMoves, color: color)
        }
            .replaceError(with: BoardStateAndMoves(boardState: BoardState.EmptyBoardState, legalMoves: [], color: .white))
            .share()

        boardStateAndMoves.sink { [weak self] boardState in
            self?.myColor = boardState.color
        }.store(in: &cancellables)

        boardStateAndMoves
            .map { boardStateAndMove in
            return boardStateAndMove.boardState
        }
            .sink { [weak self] boardState in
            guard let self else {
                return
            }
            self.board = boardState
            self._fen.send(self.board.toFowFen(color: myColor))
        }
            .store(in: &cancellables)

        payloadToBoardStateData
            .map { boardStateData in
            return boardStateData.winner
        }.replaceError(with: nil)
            .sink { [weak self] winner in
            if let winner {
                let winnerColor = ChessColor(rawValue: winner)
                self?._winner.send(winnerColor)
            } else {
                self?._winner.send(nil)
            }
        }
            .store(in: &cancellables)

        boardStateAndMoves
            .sink { [weak self] boardStateAndMoves in
            let localMoves = RemoteChessServer.boardStateAndMovesToLegalMoves(boardStateAndMoves: boardStateAndMoves)
            self?._possibleMoves.send(localMoves)
        }
            .store(in: &cancellables)
    }

    var board: BoardState = FenParser(fenStr: BoardState.DefaultFen, fowMark: "U").parse()

    var myColor: ChessColor = .white

    // Equivalent of MutableStateFlow in Kotlin
    private let _fen = CurrentValueSubject<String, Never>(BoardState.DefaultFen)
    var fen: AnyPublisher<String, Never> {
        return _fen.eraseToAnyPublisher()
    }
    var currentFen: String {
        return _fen.value
    }

    private let _possibleMoves = CurrentValueSubject<[ChessPiece: [Move]], Never>([:])
    var possibleMoves: AnyPublisher<[ChessPiece: [Move]], Never> {
        return _possibleMoves.eraseToAnyPublisher()
    }
    var currentPossibleMoves: [ChessPiece: [Move]] {
        return _possibleMoves.value
    }

    private let _winner = CurrentValueSubject<ChessColor?, Never>(nil)
    var winner: AnyPublisher<ChessColor?, Never> {
        return _winner.eraseToAnyPublisher()
    }
    var currentWinner: ChessColor? {
        return _winner.value
    }

    func applyMove(move: Move) async {
        guard let roomToken else {
            return
        }

        let moveData = MoveData(
            fromPosition: move.piece.pos.coordCode,
            toPosition: move.to.coordCode,
            promotionPiece: move.promotingTo?.shortName.lowercased() ?? ""
        )
        do {
            let boardStateData = try await ChessServiceImpl.shared.applyMove(
                data: moveData,
                token: roomToken
            )
            // emit the boardStateData to payloadToBoardStateData
            moveResultBoardStatePublisher.send(boardStateData)
        } catch {
            print("Error: \(error)")
            moveResultBoardStatePublisher.send(completion: .failure(error))
        }
    }

    func resetGame(playerColor: ChessColor) {
//        _possibleMoves.send(board.getLegalMoves(color: board.turn))
//        _fen.send(board.toFowFen(color: board.turn))
//        _winner.send(nil)
    }

    func onNextTurnStart() {
        _fen.send(board.toFowFen(color: myColor))
        _possibleMoves.send(board.getLegalMoves(color: board.turn))
    }

    static func boardStateAndMovesToLegalMoves(boardStateAndMoves: BoardStateAndMoves) -> [ChessPiece: [Move]] {
        let boardState = boardStateAndMoves.boardState
        let moves = boardStateAndMoves.legalMoves
        var validMoves = [ChessPiece: [Move]]()
        for move in moves {
            guard let fromCoord = Coord(san: move.fromPosition) else {
                continue
            }
            guard let toCoord = Coord(san: move.toPosition) else {
                continue
            }
            guard let piece = boardState.pieces[fromCoord] else {
                continue // wrong from position
            }
            let promotingTo = ChessPieceType.fromShortName(move.promotionPiece?.uppercased().first)
            let captureTarget: ChessPiece?
            if let targetPiece = boardState.pieces[toCoord] {
                // capture
                captureTarget = targetPiece
            } else if piece.type == .pawn && toCoord.file != fromCoord.file { // capture of pawn by en passant
                let enPassantPos: Coord
                if piece.color == .black {
                    enPassantPos = toCoord.offset(dr: 1, df: 0)
                } else {
                    enPassantPos = toCoord.offset(dr: -1, df: 0)
                }
                if let enPassantTarget = boardState.pieces[enPassantPos], enPassantTarget.type == .pawn {
                    captureTarget = enPassantTarget
                } else {
                    captureTarget = nil
                }
            } else {
                captureTarget = nil
            }
            let dfile = toCoord.file - fromCoord.file
            let castlingRook: ChessPiece?
            if piece.type == .king { // castling
                if dfile == 2 { // O-O
                    castlingRook = boardState.pieces[Coord(file: 8, rank: piece.rank)]
                } else if dfile == -2 { // O-O-O
                    castlingRook = boardState.pieces[Coord(file: 1, rank: piece.rank)]
                } else {
                    castlingRook = nil
                }
            } else {
                castlingRook = nil
            }

            let move = Move(piece: piece, to: toCoord, captureTarget: captureTarget, castlingRook: castlingRook, promotingTo: promotingTo)
            validMoves[piece, default: []].append(move)
        }
        return validMoves
    }
}
