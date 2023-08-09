//
//  Board+Pawn.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/08.
//

import Foundation

extension Board {
    // append move 2 or 1 if there's no blocking piece
    func appendIfNoPiece2(board: [ChessPiece], piece: ChessPiece, to result: inout [Move], candidate1: Coord, candidate2: Coord) {
        guard candidate1.isValid() && candidate2.isValid() else {
            return
        }

        if pieceAt(coord: candidate1) == nil {
            let newMove = Move(board: board, piece: piece, from: piece.pos, to: candidate1)
            result.append(newMove)

            if pieceAt(coord: candidate2) == nil {
                let newMove2 = Move(board: board, piece: piece, from: piece.pos, to: candidate2)
                result.append(newMove2)
            }
        }
    }

    func appendIfNoPiece1(board: [ChessPiece], piece: ChessPiece, to result: inout [Move], candidate: Coord) {
        guard candidate.isValid() else {
            return
        }

        if pieceAt(coord: candidate) == nil {
            let promotingTo: ChessPieceType?
            if candidate.row == 0 || candidate.row == 7 {
                promotingTo = .pawn
            } else {
                promotingTo = nil
            }
            let newMove = Move(board: board, piece: piece, from: piece.pos, to: candidate, promotingTo: promotingTo)
            result.append(newMove)
        }
    }

    func getPawnPossibleMoves(for piece: ChessPiece) -> [Move] {
        let board = toSnapshot()
        var result: [Move] = []
        if piece.color == .white { // row decreases when march forward
            if piece.row == 6 { // beginning
                appendIfNoPiece2(board: board, piece: piece, to: &result, candidate1: Coord(column: piece.column, row: piece.row - 1), candidate2: Coord(column: piece.column, row: piece.row - 2)
                )
            } else if piece.row > 0 {
                appendIfNoPiece1(board: board, piece: piece, to: &result, candidate: Coord(column: piece.column
                                                                                           , row: piece.row - 1))

            } else {
                // should have promoted
            }
        } else { // black pieces' row increases when march
            if piece.row == 1 { // beginning
                // can move 1 or 2
                appendIfNoPiece2(board: board, piece: piece, to: &result, candidate1: Coord(column: piece.column, row: piece.row + 1), candidate2: Coord(column: piece.column, row: piece.row + 2))

            } else if piece.row < 7 {
                appendIfNoPiece1(board: board, piece: piece, to: &result, candidate: Coord(column: piece.column, row: piece.row + 1))
            } else {
                // should have promoted
            }
        }
        getPawnCaptures(board: board, piece: piece, to: &result)
        getPawnEnpassant(board: board, piece: piece, history: moveHistory, to: &result)
        return result
    }

    func addMoveIfCanCapture(board: [ChessPiece], piece: ChessPiece, candidate: Coord, to result: inout [Move]) {
        if canCapture(piece: piece, target: candidate) {
            let promotingTo: ChessPieceType?
            if candidate.row == 0 || candidate.row == 7 {
                promotingTo = .pawn
            } else {
                promotingTo = nil
            }
            result.append(
                Move(
                    board: board,
                    piece: piece,
                    from: piece.pos,
                    to: candidate,
                    captureTarget: pieceAt(coord: candidate),
                    promotingTo: promotingTo
                )
            )
        }
    }

    func getPawnCaptures(board: [ChessPiece], piece: ChessPiece, to result: inout [Move]) {
        if piece.color == .white {
            addMoveIfCanCapture(board: board, piece: piece, candidate: Coord(column: piece.column - 1, row: piece.row - 1), to: &result)
            addMoveIfCanCapture(board: board, piece: piece, candidate: Coord(column: piece.column + 1, row: piece.row - 1), to: &result)
        } else {
            addMoveIfCanCapture(board: board, piece: piece, candidate: Coord(column: piece.column - 1, row: piece.row + 1), to: &result)
            addMoveIfCanCapture(board: board, piece: piece, candidate: Coord(column: piece.column + 1, row: piece.row + 1), to: &result)
        }
    }

    func getPawnEnpassant(board: [ChessPiece], piece: ChessPiece, history: [Move], to result: inout [Move]) {
        // history
        guard let lastMove = history.last else {
            return
        }
        if lastMove.piece.type != .pawn {
            return
        }
        let distance = lastMove.to.row - lastMove.from.row

        if distance != -2 && distance != 2 {
            return
        }
        if lastMove.to.column != piece.column - 1 && lastMove.to.column != piece.column + 1 {
            return
        }
        if lastMove.to.row != piece.row {
            return
        }
        let newMove = Move(board: board, piece: piece, from: piece.pos
                           , to: Coord(column: lastMove.to.column, row: lastMove.to.row - distance / 2), captureTarget: pieceAt(coord: lastMove.to))
        result.append(newMove)
    }
}
