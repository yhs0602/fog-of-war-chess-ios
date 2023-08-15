//
//  BoardState+Move.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/15.
//

import Foundation

extension BoardState {
    func getKnightMoves(piece: ChessPiece) -> [Move] {
        var moves: [Move] = []
        let dx = [1, 2, 2, 1, -1, -2, -2, -1]
        let dy = [2, 1, -1, -2, -2, -1, 1, 2]

        for i in 0..<8 {
            let target = Coord(file: piece.file + dy[i], rank: piece.rank + dx[i])
            addMoveIfNotBlocked(moves: &moves, piece: piece, target: target, canCapture: true)
        }

        return moves
    }

    func getBishopMoves(piece: ChessPiece) -> [Move] {
        var moves: [Move] = []
        let directions = [
            (1, 1), // up right
            (1, -1), // up left
            (-1, 1), // down right
            (-1, -1) // down left
        ]

        for dir in directions {
            for i in 1...7 {
                let target = Coord(file: piece.file + dir.1 * i, rank: piece.rank + dir.0 * i)
                if addMoveIfNotBlocked(moves: &moves, piece: piece, target: target) {
                    break
                }
            }
        }

        return moves
    }

    func getRookMoves(piece: ChessPiece) -> [Move] {
        var moves: [Move] = []
        let directions = [
            (1, 0), // up
            (-1, 0), // down
            (0, 1), // right
            (0, -1) // left
        ]

        for dir in directions {
            for i in 1...7 {
                let target = Coord(file: piece.file + dir.1 * i, rank: piece.rank + dir.0 * i)
                if addMoveIfNotBlocked(moves: &moves, piece: piece, target: target) {
                    break
                }
            }
        }

        return moves
    }

    func getQueenMoves(piece: ChessPiece) -> [Move] {
        return getRookMoves(piece: piece) + getBishopMoves(piece: piece)
    }


    func getKingMoves(piece: ChessPiece) -> [Move] {
        var moves: [Move] = []
        let dx = [1, 1, 1, 0, 0, -1, -1, -1]
        let dy = [1, 0, -1, 1, -1, 1, 0, -1]

        for i in 0..<8 {
            let target = Coord(file: piece.file + dy[i], rank: piece.rank + dx[i])
            addMoveIfNotBlocked(moves: &moves, piece: piece, target: target, canCapture: true)
        }

        // castling
        // king side rook (right rook)
        if castling[piece.color]?[0] == true {
            let rightRook = pieces[Coord(file: 8, rank: piece.rank)]
            if rightRook != nil {
                // check if there are no pieces between king and rook
                if (piece.file + 1..<rightRook!.file).allSatisfy({ pieces[Coord(file: $0, rank: piece.rank)] == nil }) {
                    moves.append(
                        Move(
                            piece: piece,
                            to: Coord(file: piece.file + 2, rank: piece.rank),
                            castlingRook: rightRook
                        )
                    )
                }
            }
        }

        // queen side rook (left rook)
        if castling[piece.color]?[1] == true {
            let leftRook = pieces[Coord(file: 1, rank: piece.rank)]
            if leftRook != nil {
                // check if there are no pieces between king and rook
                if (leftRook!.file + 1..<piece.file).allSatisfy({ pieces[Coord(file: $0, rank: piece.rank)] == nil }) {
                    moves.append(
                        Move(
                            piece: piece,
                            to: Coord(file: piece.file - 2, rank: piece.rank),
                            castlingRook: leftRook
                        )
                    )
                }
            }
        }

        return moves
    }

}
