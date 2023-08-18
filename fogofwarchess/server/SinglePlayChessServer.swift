//
//  SinglePlayChessServer.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/15.
//

import Foundation
import Combine

class SinglePlayChessServer: ChessServer {
    static let shared = SinglePlayChessServer()

    private init() {

    }

    var board: BoardState = FenParser(fenStr: BoardState.DefaultFen, fowMark: "U").parse()
    var _fen: CurrentValueSubject<String, Never> = CurrentValueSubject<String, Never>(BoardState.DefaultFen)
    var _possibleMoves: CurrentValueSubject<[ChessPiece: [Move]], Never> = CurrentValueSubject<[ChessPiece: [Move]], Never>([:])
    var _winner: CurrentValueSubject<ChessColor?, Never> = CurrentValueSubject<ChessColor?, Never>(nil)

    var fen: AnyPublisher<String, Never> {
        _fen.eraseToAnyPublisher()
    }

    var possibleMoves: AnyPublisher<[ChessPiece: [Move]], Never> {
        _possibleMoves.eraseToAnyPublisher()
    }

    var winner: AnyPublisher<ChessColor?, Never> {
        _winner.eraseToAnyPublisher()
    }
    var currentFen: String {
        return _fen.value
    }
    var currentPossibleMoves: [ChessPiece: [Move]] {
        return _possibleMoves.value
    }
    var currentWinner: ChessColor? {
        return _winner.value
    }

    private var playerColor: ChessColor!
    private var computerColor: ChessColor!

    func applyMove(move: Move) async {
        let newState = BoardState.applyMove(board, move)
        board = newState.0
        let winner = newState.1
        _fen.value = board.toFowFen(color: board.turn.opposite)

        if let winner = winner {
            self._winner.value = winner
        } else {
            doComputerMove()
        }
    }

    private func doComputerMove() {
        let computerMoves = board.getLegalMoves(color: board.turn).values.flatMap { $0 }
        let computerMove = getComputerMove(computerViewingBoard: board.toFowBoard(color: board.turn), candidates: computerMoves)
        let newComputerState = BoardState.applyMove(board, computerMove)
        board = newComputerState.0
        let computerWinner = newComputerState.1
        _fen.value = board.toFowFen(color: board.turn)
        _possibleMoves.value = board.getLegalMoves(color: board.turn)

        if let computerWinner = computerWinner {
            self._winner.value = computerWinner
        }
    }

    func resetGame(playerColor: ChessColor) {
        print("ResetGame \(playerColor)")
        board = FenParser(fenStr: BoardState.DefaultFen, fowMark: "U").parse()
        print("parsed")
        _possibleMoves.value = board.getLegalMoves(color: board.turn)
        _fen.value = board.toFowFen(color: board.turn)
        print("set value of possiblemoves and fen")
        self.playerColor = playerColor
        self.computerColor = playerColor.opposite
        print("Set variables")
        _winner.value = nil
        if playerColor == .black {
            print("Do computer move")
            doComputerMove()
        }
    }

    func onNextTurnStart() {
        // do nothing
    }

    private func getComputerMove(computerViewingBoard: BoardState, candidates: [Move]) -> Move {
        // Score the moves
        var shuffledCandidates = candidates.shuffled()
        var bestMove = shuffledCandidates.first!
        var bestScore = -10000

        for move in shuffledCandidates {
            // Simulate the board and evaluate the score
            let (newBoard, winner) = BoardState.applyMove(computerViewingBoard, move)
            if winner == computerColor { // End the game winning
                return move
            }

            // Simulate the opponent's move based on the new board
            // Find the threat to the king in the new board
            let newOpponentMoves = newBoard.getLegalMoves(color: playerColor).values.flatMap { $0 }
            let opponentCaptureTargets = newOpponentMoves.compactMap { $0.captureTarget }

            if opponentCaptureTargets.contains(where: { $0.type == .king }) {
                continue // Avoid the move
            }

            let originalValue = move.captureTarget?.type.value ?? 0
            let losingValue = opponentCaptureTargets.map { $0.type.value }.max() ?? (move.piece.type.value / 2)
            var score = originalValue - losingValue // Avoid bait

            if move.castlingRook != nil {
                score += 1 // Castling is good
            }

            if move.to.file >= 3 && move.to.file <= 6 && move.to.rank >= 3 && move.to.rank <= 6 {
                score += 1 // Moving to the center is good
            }

            // Opening the king is bad
            if let myKing = newBoard.pieces.values.first(where: { $0.type == .king }) {
                // Search for the pawns in front of the king
                var numMyPawn = 0
                var numOpponentPawn = 0

                for i in 1...7 {
                    if let pawn = newBoard.pieces[myKing.pos.offset(dr: i, df: 0)],
                        pawn.type == .pawn {
                        if pawn.color == computerColor {
                            numMyPawn += 1
                        } else {
                            numOpponentPawn += 1
                        }
                    }
                }

                score += (numMyPawn + numOpponentPawn / 2 - 1)
            }

            // Moving the f pawn is bad
            if move.piece.type == .pawn && move.piece.file == 6 && (move.piece.rank == 2 || move.piece.rank == 7) {
                score -= 3
            }

            if score > bestScore {
                bestScore = score
                bestMove = move
            }
        }

        return bestMove
    }
}
