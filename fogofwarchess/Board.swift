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
        // Place black pieces
        place(piece: ChessPiece(type: .rook, color: .black, pos: Coord(column: 0, row: 0)), at: 0, column: 0)
        place(piece: ChessPiece(type: .knight, color: .black, pos: Coord(column: 1, row: 0)), at: 0, column: 1)
        place(piece: ChessPiece(type: .bishop, color: .black, pos: Coord(column: 2, row: 0)), at: 0, column: 2)
        place(piece: ChessPiece(type: .queen, color: .black, pos: Coord(column: 3, row: 0)), at: 0, column: 3)
        place(piece: ChessPiece(type: .king, color: .black, pos: Coord(column: 4, row: 0)), at: 0, column: 4)
        place(piece: ChessPiece(type: .bishop, color: .black, pos: Coord(column: 5, row: 0)), at: 0, column: 5)
        place(piece: ChessPiece(type: .knight, color: .black, pos: Coord(column: 6, row: 0)), at: 0, column: 6)
        place(piece: ChessPiece(type: .rook, color: .black, pos: Coord(column: 7, row: 0)), at: 0, column: 7)

        for column in 0..<8 {
            place(piece: ChessPiece(type: .pawn, color: .black, pos: Coord(column: column, row: 1)), at: 1, column: column)
        }

        // Place white pieces
        place(piece: ChessPiece(type: .rook, color: .white, pos: Coord(column: 0, row: 7)), at: 7, column: 0)
        place(piece: ChessPiece(type: .knight, color: .white, pos: Coord(column: 1, row: 7)), at: 7, column: 1)
        place(piece: ChessPiece(type: .bishop, color: .white, pos: Coord(column: 2, row: 7)), at: 7, column: 2)
        place(piece: ChessPiece(type: .queen, color: .white, pos: Coord(column: 3, row: 7)), at: 7, column: 3)
        place(piece: ChessPiece(type: .king, color: .white, pos: Coord(column: 4, row: 7)), at: 7, column: 4)
        place(piece: ChessPiece(type: .bishop, color: .white, pos: Coord(column: 5, row: 7)), at: 7, column: 5)
        place(piece: ChessPiece(type: .knight, color: .white, pos: Coord(column: 6, row: 7)), at: 7, column: 6)
        place(piece: ChessPiece(type: .rook, color: .white, pos: Coord(column: 7, row: 7)), at: 7, column: 7)

        for column in 0..<8 {
            place(piece: ChessPiece(type: .pawn, color: .white, pos: Coord(column: column, row: 6)), at: 6, column: column)
        }
    }

    // returns the winner by this move
    func apply(move: Move) -> ChessColor? {
        let piece = move.piece
        let fromRow = move.from.row
        let fromColumn = move.from.column
        let toRow = move.to.row
        let toColumn = move.to.column

        if let captureTarget = move.captureTarget { // en passant
            squares[captureTarget.row][captureTarget.column] = nil
        }

        piece.pos = move.to
        squares[toRow][toColumn] = piece
        squares[fromRow][fromColumn] = nil

        moveHistory.append(move)
        if let captureTarget = move.captureTarget {
            if captureTarget.type == .king {
                return move.piece.color // game end
            }
        }
        return nil
    }

    // returns to continue
    func captureOrMove(board: [ChessPiece], piece: ChessPiece, targetCoord: Coord, to result: inout [Move]) -> Bool {
        guard let targetPiece = pieceAt(coord: targetCoord) else {
            result.append(Move(board: board, piece: piece, from: piece.pos, to: targetCoord))
            return true
        }

        if targetPiece.color != piece.color {
            result.append(Move(board: board, piece: piece, from: piece.pos, to: targetCoord, captureTarget: targetPiece))
        }
        return false
    }

    func getRookPossibleMoves(board: [ChessPiece], piece: ChessPiece) -> [Move] {
        var result = [Move]()

        // Extend to 4 directions
        if piece.column < 7 {
            for i in (piece.column + 1)...7 {
                let targetCoord = Coord(column: i, row: piece.row)
                if captureOrMove(board: board, piece: piece, targetCoord: targetCoord, to: &result) {
                    continue
                } else {
                    break
                }
            }
        }

        if piece.column > 0 {
            for i in stride(from: piece.column - 1, through: 0, by: -1) {
                let targetCoord = Coord(column: i, row: piece.row)
                if captureOrMove(board: board, piece: piece, targetCoord: targetCoord, to: &result) {
                    continue
                } else {
                    break
                }
            }
        }

        if piece.row < 7 {
            for i in (piece.row + 1)...7 {
                let targetCoord = Coord(column: piece.column, row: i)
                if captureOrMove(board: board, piece: piece, targetCoord: targetCoord, to: &result) {
                    continue
                } else {
                    break
                }
            }
        }

        if piece.row > 0 {
            for i in stride(from: piece.row - 1, through: 0, by: -1) {
                let targetCoord = Coord(column: piece.column, row: i)
                if captureOrMove(board: board, piece: piece, targetCoord: targetCoord, to: &result) {
                    continue
                } else {
                    break
                }
            }
        }
        return result
    }

    func getBishopPossibleMoves(board: [ChessPiece], piece: ChessPiece) -> [Move] {
        var result = [Move]()

        // Extend to 4 diagonals
        for i in 1...7 {
            let targetCoord = Coord(column: piece.column + i, row: piece.row + i)
            if !targetCoord.isValid() {
                break
            }
            if captureOrMove(board: board, piece: piece, targetCoord: targetCoord, to: &result) {
                continue
            } else {
                break
            }
        }

        for i in 1...7 {
            let targetCoord = Coord(column: piece.column - i, row: piece.row + i)
            if !targetCoord.isValid() {
                break
            }
            if captureOrMove(board: board, piece: piece, targetCoord: targetCoord, to: &result) {
                continue
            } else {
                break
            }
        }

        for i in 1...7 {
            let targetCoord = Coord(column: piece.column + i, row: piece.row - i)
            if !targetCoord.isValid() {
                break
            }
            if captureOrMove(board: board, piece: piece, targetCoord: targetCoord, to: &result) {
                continue
            } else {
                break
            }
        }

        for i in 1...7 {
            let targetCoord = Coord(column: piece.column - i, row: piece.row - i)
            if !targetCoord.isValid() {
                break
            }
            if captureOrMove(board: board, piece: piece, targetCoord: targetCoord, to: &result) {
                continue
            } else {
                break
            }
        }

        return result
    }

    func getKnightPossibleMoves(board: [ChessPiece], piece: ChessPiece) -> [Move] {
        var result = [Move]()

        let possibleMoves: [(Int, Int)] = [
            (1, 2), (2, 1), (-1, 2), (-2, 1),
            (1, -2), (2, -1), (-1, -2), (-2, -1)
        ]

        for move in possibleMoves {
            let targetCoord = Coord(column: piece.column + move.0, row: piece.row + move.1)
            if targetCoord.isValid() {
                if let targetPiece = pieceAt(coord: targetCoord) {
                    if targetPiece.color != piece.color {
                        result.append(Move(board: board, piece: piece, from: piece.pos, to: targetCoord, captureTarget: targetPiece))
                    }
                } else {
                    result.append(Move(board: board, piece: piece, from: piece.pos, to: targetCoord))
                }
            }
        }

        return result
    }

    func getQueenPossibleMoves(board: [ChessPiece], piece: ChessPiece) -> [Move] {
        let r = getRookPossibleMoves(board: board, piece: piece)
        let b = getBishopPossibleMoves(board: board, piece: piece)
        return r + b
    }

    func getKingPossibleMoves(board: [ChessPiece], piece: ChessPiece) -> [Move] {
        var result = [Move]()

        let possibleMoves: [(Int, Int)] = [
            (1, 0), (1, 1), (0, 1), (-1, 0),
            (-1, -1), (0, -1), (1, -1), (-1, 1)
        ]

        for move in possibleMoves {
            let targetCoord = Coord(column: piece.column + move.0, row: piece.row + move.1)
            if targetCoord.isValid() {
                if let targetPiece = pieceAt(coord: targetCoord) {
                    if targetPiece.color != piece.color {
                        result.append(Move(board: board, piece: piece, from: piece.pos, to: targetCoord, captureTarget: targetPiece))
                    }
                } else {
                    result.append(Move(board: board, piece: piece, from: piece.pos, to: targetCoord))
                }
            }
        }

        return result
    }

    func getPossibleMovesWithoutPawn(piece: ChessPiece) -> [Move] {
        let board = toSnapshot()
        switch piece.type {
        case .rook:
            return getRookPossibleMoves(board: board, piece: piece)
        case .knight:
            return getKnightPossibleMoves(board: board, piece: piece)
        case .bishop:
            return getBishopPossibleMoves(board: board, piece: piece)
        case .queen:
            return getQueenPossibleMoves(board: board, piece: piece)
        case .king:
            return getKingPossibleMoves(board: board, piece: piece)
        default: // error: Pawn should not be called
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

    func toSnapshot() -> [ChessPiece] {
        var result: [ChessPiece] = []
        for row in squares {
            for square in row {
                if let piece = square {
                    result.append(
                        ChessPiece(type: piece.type
                                   , color: piece.color, pos: piece.pos)
                    )
                }
            }
        }
        return result
    }
}
