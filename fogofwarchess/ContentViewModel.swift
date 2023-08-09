//
//  ContentViewModel.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/08.
//

import Foundation
import SwiftUI

enum GamePhase: String {
    case playing, white_win, black_win
}

class ContentViewModel: ObservableObject {
    @Published var board: Board
    @Published var selectedPiece: ChessPiece?
    @Published var possibleMoves: [Move] = [] {
        willSet {
            moveAt = [:]
            for move in newValue {
                moveAt[move.to] = move
            }
        }
    }
    @Published var currentColor: ChessColor = .white
    @Published var gamePhase: GamePhase = .playing
    @Published var moveAt: [Coord: Move] = [:]
    @Published var promotingPawn: ChessPiece?
    @Published var isVisibleCoord: [Coord: Bool] = [:]

    init() {
        self.board = Board()
        self.selectedPiece = nil
        self.possibleMoves = []
        self.board.initializePieces()
        calculateVisibleCoords()
    }

    func cellTapped(row: Int, column: Int) {
        if selectedPiece != nil {
            // Check if the cell is in possible moves
            if let theMove = possibleMoves.first(where: { move in
                move.to.row == row && move.to.column == column
            }) {
                movePiece(move: theMove)
            } else {
                selectPiece(row: row, column: column)
            }
        } else {
            selectPiece(row: row, column: column)
        }
    }

    func selectPiece(row: Int, column: Int) {
        // Select a piece if available
        if let piece = board.pieceAt(row: row, column: column) {
            if piece.color == currentColor {
                selectedPiece = piece
                possibleMoves = calculatePossibleMoves(for: piece)
                return
            }
        }
        selectedPiece = nil
        possibleMoves = []
    }

    func movePiece(move: Move) {
        // TODO: play sound based on capture target
        let winner = board.apply(move: move)
        possibleMoves = []
        switch winner {
        case nil:
            if move.promotingTo != nil {
                promotingPawn = move.piece
                return
            }
            selectedPiece = nil
            swapTurn()
        case .black:
            gamePhase = .black_win

        case .white:
            gamePhase = .white_win
        }
    }

    func swapTurn() {
        currentColor = currentColor.opposite
        calculateVisibleCoords()
    }

    func pieceAt(row: Int, column: Int) -> ChessPiece? {
        return board.pieceAt(row: row, column: column)
    }

    func isValidMove(_ move: Move) -> Bool {
        // Implement your move validation logic here
        // For simplicity, this function always returns true
        return true
    }

    func calculatePossibleMoves(for piece: ChessPiece) -> [Move] {
        // Calculate and update possibleMoves based on piece's rules
        if piece.type == .pawn {
            return board.getPawnPossibleMoves(for: piece)
        } else {
            return board.getPossibleMovesWithoutPawn(piece: piece)
        }
    }

    func moveAt(row: Int, column: Int) -> Move? {
        return moveAt[Coord(column: column, row: row)] ?? nil
    }

    var historyPgn: String {
        return board.moveHistory.map { move in
            move.getPgn(board: board)
        }.joined(separator: " ")
    }

    func promote(pieceType: ChessPieceType) {
        guard let promotingPawn else {
            return
        }
        let winner = board.apply(
            move: Move(
                board: board.toSnapshot(),
                piece: promotingPawn,
                from: promotingPawn.pos,
                to: promotingPawn.pos,
                promotingTo: pieceType
            )
        )
        self.promotingPawn = nil
        selectedPiece = nil
        swapTurn()
        possibleMoves = []
        switch winner {
        case nil:
            break
        case .black:
            gamePhase = .black_win
        case .white:
            gamePhase = .white_win
        }
    }

    func calculateVisibleCoords() {
        isVisibleCoord = [Coord: Bool]() // reset the map
        board.pieces(color: currentColor).forEach {
            let moves: [Move]
            if $0.type == .pawn {
                moves = board.getPawnPossibleMoves(for: $0)
            } else {
                moves = board.getPossibleMovesWithoutPawn(piece: $0)
            }
            for move in moves {
                isVisibleCoord[move.to] = true
            }
            isVisibleCoord[$0.pos] = true
        }
    }

    func reset() {
        board = Board()
        currentColor = .white
        gamePhase = .playing
        selectedPiece = nil
        possibleMoves = []
        promotingPawn = nil
        calculateVisibleCoords()
    }
}
