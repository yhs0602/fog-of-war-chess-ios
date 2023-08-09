//
//  Board+Pawn.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/08.
//

import Foundation

extension Board {
    // append move 2 or 1 if there's no blocking piece
    func appendIfNoPiece2(piece: ChessPiece, to result: inout [Move], candidate1: Coord, candidate2: Coord) {
        guard candidate1.isValid() && candidate2.isValid() else {
            return
        }

        if pieceAt(coord: candidate1) == nil {
            let newMove = Move(piece: piece, from: piece.pos, to: candidate1)
            result.append(newMove)

            if pieceAt(coord: candidate2) == nil {
                let newMove2 = Move(piece: piece, from: piece.pos, to: candidate2)
                result.append(newMove2)
            }
        }
    }

    func appendIfNoPiece1(piece: ChessPiece, to result: inout [Move], candidate: Coord) {
        guard candidate.isValid() else {
            return
        }

        if pieceAt(coord: candidate) == nil {
            let newMove = Move(piece: piece, from: piece.pos, to: candidate)
            result.append(newMove)
        }
    }

    func getPawnPossibleMoves(for piece: ChessPiece) -> [Move] {
        var result: [Move] = []
        if piece.color == .white { // row decreases when march forward
            if piece.row == 6 { // beginning
                appendIfNoPiece2(piece: piece, to: &result, candidate1: Coord(column: piece.column, row: piece.row - 1), candidate2: Coord(column: piece.column, row: piece.row - 2)
                )
            } else if piece.row > 0 {
                appendIfNoPiece1(piece: piece, to: &result, candidate: Coord(column: piece.column
                                                                             , row: piece.row - 1))

            } else {
                // should have promoted
            }
        } else { // black pieces' row increases when march
            if piece.row == 1 { // beginning
                // can move 1 or 2
                appendIfNoPiece2(piece: piece, to: &result, candidate1: Coord(column: piece.column, row: piece.row + 1), candidate2: Coord(column: piece.column, row: piece.row + 2))

            } else if piece.row < 7 {
                appendIfNoPiece1(piece: piece, to: &result, candidate: Coord(column: piece.column, row: piece.row + 1))
            } else {
                // should have promoted
            }
        }
        getPawnCaptures(piece: piece, to: &result)
        getPawnEnpassant(result)
        return result
    }

    func addMoveIfCanCapture(piece: ChessPiece, candidate: Coord, to result: inout [Move]) {
        if canCapture(piece: piece, target: candidate) {
            result.append(Move(piece: piece, from: piece.pos, to: candidate))
        }
    }

    func getPawnCaptures(piece: ChessPiece, to result: inout [Move]) {
        if piece.color == .white {
            addMoveIfCanCapture(piece: piece, candidate: Coord(column: piece.column - 1, row: piece.row - 1), to: &result)
            addMoveIfCanCapture(piece: piece, candidate: Coord(column: piece.column + 1, row: piece.row - 1), to: &result)
        } else {
            addMoveIfCanCapture(piece: piece, candidate: Coord(column: piece.column - 1, row: piece.row + 1), to: &result)
            addMoveIfCanCapture(piece: piece, candidate: Coord(column: piece.column + 1, row: piece.row + 1), to: &result)
        }
    }

    func getPawnEnpassant(piece: ChessPiece, history: [Move], to result: inout [Move]) {
        // history
        guard let lastMove = history.last else {
            return
        }
        if lastMove.piece.type != .pawn {
            return
        }
        let distance = lastMove.to.row - lastMove.from.row
        if distance != -2 || distance != 2 {
            return
        }
        if lastMove.to.column != piece.column - 1 || lastMove.to.column != piece.column + 1 {
            return
        }
        if lastMove.to.row != piece.row {
            return
        }
        let newMove = Move(piece: piece, from: piece.pos
                           , to: lastMove.to)
        result.append(newMove)
    }
}
