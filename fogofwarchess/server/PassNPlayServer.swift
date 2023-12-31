//
//  PassNPlayServer.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/15.
//

import Foundation
import Combine

class PassNPlayChessServer: ChessServer {
    static let shared = PassNPlayChessServer()

    private init() {

    }

    var board: BoardState = FenParser(fenStr: BoardState.DefaultFen, fowMark: "U").parse()

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
        // submit the move to the server
        // emit the updated fen, possible moves, etc.
        let newState = BoardState.applyMove(self.board, move)
        self.board = newState.0
        let winner = newState.1
        self._fen.send(self.board.toFowFen(color: self.board.turn.opposite))
        if let winner = winner {
            self._winner.send(winner)
        } else {
            // wait for the next turn signal, for simplicity sending success here
        }
    }

    func resetGame(playerColor: ChessColor) {
        board = FenParser(fenStr: BoardState.DefaultFen, fowMark: "U").parse()
        _possibleMoves.send(board.getLegalMoves(color: board.turn))
        _fen.send(board.toFowFen(color: board.turn))
        _winner.send(nil)
    }

    func onNextTurnStart() {
        _fen.send(board.toFowFen(color: board.turn))
        _possibleMoves.send(board.getLegalMoves(color: board.turn))
    }
}
