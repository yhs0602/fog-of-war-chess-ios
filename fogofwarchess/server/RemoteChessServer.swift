//
//  RemoteChessServer.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/15.
//

import Foundation
import Combine

class RemoteChessServer: ChessServer {
    static let shared = RemoteChessServer()
    var cancellables = Set<AnyCancellable>()
    @Published private var roomToken: String? = UserDefaults.standard.roomToken

    private init() {
        let payloadToBoardStateData = NotificationManager.shared.payloadSubject
            .tryMap { payload in
            guard let data = payload.data(using: .utf8) else {
                throw NSError(domain: "Invalid payload", code: 0, userInfo: nil)
            }
            let decoder = JSONDecoder()
            return try decoder.decode(BoardStateData.self, from: data)
        }

        let boardStateAndMoves = payloadToBoardStateData
            .map { boardStateData -> BoardStateAndMoves in
            let boardState = FenParser(fenStr: boardStateData.board, fowMark: "U").parse()
            return BoardStateAndMoves(boardState: boardState, legalMoves: boardStateData.legalMoves)
        } .replaceError(with: BoardStateAndMoves(boardState: BoardState.EmptyBoardState, legalMoves: []))
            .share()

        boardStateAndMoves
            .map { boardStateAndMove in
            return boardStateAndMove.boardState
        }.sink { [weak self] boardState in
            self?.board = boardState
        }.store(in: &cancellables)

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

    // Equivalent of MutableStateFlow in Kotlin
    private let _fen = CurrentValueSubject<String, Never>(BoardState.DefaultFen)
    var fen: AnyPublisher<String, Never> {
        return _fen.eraseToAnyPublisher()
    }

    private let _possibleMoves = CurrentValueSubject<[ChessPiece: [Move]], Never>([:])
    var possibleMoves: AnyPublisher<[ChessPiece: [Move]], Never> {
        return _possibleMoves.eraseToAnyPublisher()
    }

    private let _winner = CurrentValueSubject<ChessColor?, Never>(nil)
    var winner: AnyPublisher<ChessColor?, Never> {
        return _winner.eraseToAnyPublisher()
    }

    func applyMove(move: Move) -> Future<Void, Error> {
        return Future { [weak self] promise in
            guard let self else {
                return
            }
            guard let roomToken else {
                return
            }

            let moveData = MoveData(
                fromPosition: move.piece.pos.coordCode,
                toPosition: move.to.coordCode,
                promotionPiece: move.promotingTo?.rawValue ?? ""
            )
            Task {
                do {
                    let roomData = try await ChessServiceImpl.shared.applyMove(
                        data: moveData,
                        token: roomToken
                    )
                } catch {
                    print("Error: \(error)")
                }
            }
            promise(.success(()))
        }
    }

    func resetGame(playerColor: ChessColor) {
        // do nothing
        //        board = FenParser(fenStr: BoardState.DefaultFen, fowMark: "U").parse()
        //        _possibleMoves.send(board.getLegalMoves(color: board.turn))
        //        _fen.send(board.toFowFen(color: board.turn))
        //        _winner.send(nil)
    }

    func onNextTurnStart() {
        _fen.send(board.toFowFen(color: board.turn))
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
            let promotingTo = ChessPieceType(rawValue: move.promotionPiece)
            // TODO: handle capture piece w en passant
            // TODO: handle castling rook
            let move = Move(piece: piece, to: toCoord, captureTarget: nil, castlingRook: nil, promotingTo: promotingTo)
            validMoves[piece]?.append(move) // TODO: Default empty
        }
        return validMoves
    }
}
