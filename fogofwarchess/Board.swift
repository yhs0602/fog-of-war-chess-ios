//
//  Board.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/08.
//

import Foundation

class Board: ObservableObject {
    @Published var squares: [[ChessPiece?]] = Array(repeating: Array(repeating: nil, count: 8), count: 8)
    var moveHistory: [Move] = []

    func place(piece: ChessPiece, at row: Int, column: Int) {
        squares[row][column] = piece
        piece.pos = Coord(column: column, row: row)
    }

    func pieceAt(row: Int, column: Int) -> ChessPiece? {
        return squares[row][column]
    }

    func pieceAt(coord: Coord) -> ChessPiece? {
        return pieceAt(row: coord.row, column: coord.column)
    }

    func removePieceAt(row: Int, column: Int) {
        squares[row][column] = nil
    }

    func initializePieces() {
        // Place white pieces
        place(piece: ChessPiece(type: .rook, color: .white, pos: Coord(column: 0, row: 0)), at: 0, column: 0)
        place(piece: ChessPiece(type: .knight, color: .white, pos: Coord(column: 1, row: 0)), at: 0, column: 1)
        place(piece: ChessPiece(type: .bishop, color: .white, pos: Coord(column: 2, row: 0)), at: 0, column: 2)
        place(piece: ChessPiece(type: .queen, color: .white, pos: Coord(column: 3, row: 0)), at: 0, column: 3)
        place(piece: ChessPiece(type: .king, color: .white, pos: Coord(column: 4, row: 0)), at: 0, column: 4)
        place(piece: ChessPiece(type: .bishop, color: .white, pos: Coord(column: 5, row: 0)), at: 0, column: 5)
        place(piece: ChessPiece(type: .knight, color: .white, pos: Coord(column: 6, row: 0)), at: 0, column: 6)
        place(piece: ChessPiece(type: .rook, color: .white, pos: Coord(column: 7, row: 0)), at: 0, column: 7)

        for column in 0..<8 {
            place(piece: ChessPiece(type: .pawn, color: .white, pos: Coord(column: column, row: 1)), at: 1, column: column)
        }

        // Place black pieces
        place(piece: ChessPiece(type: .rook, color: .black, pos: Coord(column: 0, row: 7)), at: 7, column: 0)
        place(piece: ChessPiece(type: .knight, color: .black, pos: Coord(column: 1, row: 7)), at: 7, column: 1)
        place(piece: ChessPiece(type: .bishop, color: .black, pos: Coord(column: 2, row: 7)), at: 7, column: 2)
        place(piece: ChessPiece(type: .queen, color: .black, pos: Coord(column: 3, row: 7)), at: 7, column: 3)
        place(piece: ChessPiece(type: .king, color: .black, pos: Coord(column: 4, row: 7)), at: 7, column: 4)
        place(piece: ChessPiece(type: .bishop, color: .black, pos: Coord(column: 5, row: 7)), at: 7, column: 5)
        place(piece: ChessPiece(type: .knight, color: .black, pos: Coord(column: 6, row: 7)), at: 7, column: 6)
        place(piece: ChessPiece(type: .rook, color: .black, pos: Coord(column: 7, row: 7)), at: 7, column: 7)

        for column in 0..<8 {
            place(piece: ChessPiece(type: .pawn, color: .black, pos: Coord(column: column, row: 6)), at: 6, column: column)
        }
    }

    // returns the winner by this move
    func apply(move: Move) -> ChessColor? {
        let piece = move.piece
        let fromRow = move.from.row
        let fromColumn = move.from.column
        let toRow = move.to.row
        let toColumn = move.to.column

        piece.pos = move.to
        squares[toRow][toColumn] = piece
        squares[fromRow][fromColumn] = nil

        moveHistory.append(move)
        return nil
    }

    func getRookPossibleMoves(piece: ChessPiece) -> [Move] {
        var result = [Move]()

        // Extend to 4 directions
        for i in (piece.column + 1)...7 {
            guard let targetPiece = pieceAt(coord: Coord(column: i, row: piece.row)) else {
                result.append(Move(piece: piece, from: piece.pos, to: Coord(column: i, row: piece.row)))
                continue
            }

            if targetPiece.color != piece.color {
                result.append(Move(from: piece.pos, to: Coord(column: i, row: piece.row), piece: piece, captureTarget: targetPiece))
            }
            break
        }

        for i in (piece.column - 1).stride(through: 0, by: -1) {
            guard let targetPiece = board.getPiece(at: Coord(column: i, row: piece.row)) else {
                result.append(Move(from: piece.pos, to: Coord(column: i, row: piece.row), piece: piece))
                continue
            }

            if targetPiece.color != piece.color {
                result.append(Move(from: piece.pos, to: Coord(column: i, row: piece.row), piece: piece, captureTarget: targetPiece))
            }
            break
        }

        for i in (piece.row + 1)...7 {
            guard let targetPiece = board.getPiece(at: Coord(column: piece.column, row: i)) else {
                result.append(Move(from: piece.pos, to: Coord(column: piece.column, row: i), piece: piece))
                continue
            }

            if targetPiece.color != piece.color {
                result.append(Move(from: piece.pos, to: Coord(column: piece.column, row: i), piece: piece, captureTarget: targetPiece))
            }
            break
        }

        for i in (piece.row - 1).stride(through: 0, by: -1) {
            guard let targetPiece = board.getPiece(at: Coord(column: piece.column, row: i)) else {
                result.append(Move(from: piece.pos, to: Coord(column: piece.column, row: i), piece: piece))
                continue
            }

            if targetPiece.color != piece.color {
                result.append(Move(from: piece.pos, to: Coord(column: piece.column, row: i), piece: piece, captureTarget: targetPiece))
            }
            break
        }

        return result
    }

    func getPossibleMovesWithoutPawn(piece: ChessPiece) -> [Move] {
        switch piece.type {
        case .rook:
            return []
        case .knight:
            return []
        case .bishop:
            return []
        case .queen:
            return []
        case .king:
            return []
        default:
            return []
        }
    }

    func canCapture(piece: ChessPiece, target: Coord) -> Bool {
        guard target.isValid() else {
            return false
        }
        guard let targetPiece = pieceAt(coord: target) else {
            return false
        }
        return targetPiece.color != piece.color
    }
}
