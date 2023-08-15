//
//  BoardState+Move.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/15.
//

import Foundation

extension BoardState {
    func getPawnMoves(piece: ChessPiece) -> [Move] {
        switch piece.color {
        case .white:
            return getWhitePawnMoves(piece: piece)
        case .black:
            return getBlackPawnMoves(piece: piece)
        }
    }

    func addMoveIfNotBlocked(
        moves: inout [Move],
        piece: ChessPiece,
        target: Coord,
        canCapture: Bool = true,
        canPromote: Bool = false,
        mustCapture: Bool = false
    ) -> Bool {

        if target.file < 1 || target.file > 8 || target.rank < 1 || target.rank > 8 {
            return true // invalid target
        }

        if let targetPiece = pieces[target] {
            if targetPiece.color != piece.color && canCapture {
                if canPromote {
                    let promotionTypes: [ChessPieceType] = [.queen, .rook, .bishop, .knight]
                    for type in promotionTypes {
                        moves.append(
                            Move(piece: piece, to: target, captureTarget: targetPiece, promotingTo: type)
                        )
                    }
                } else {
                    moves.append(Move(piece: piece, to: target, captureTarget: targetPiece))
                }
            }
            return true
        } else {
            if !mustCapture {
                if canPromote {
                    let promotionTypes: [ChessPieceType] = [.queen, .rook, .bishop, .knight]
                    for type in promotionTypes {
                        moves.append(
                            Move(piece: piece, to: target, promotingTo: type)
                        )
                    }
                } else {
                    moves.append(Move(piece: piece, to: target))
                }
            }
            return false
        }
    }

    private func getWhitePawnMoves(piece: ChessPiece) -> [Move] {
        var moves: [Move] = []

        // march 1 or 2 squares forward : rank increases
        switch piece.rank {
        case 2:  // can move two squares
            if !addMoveIfNotBlocked(
                moves: &moves,
                piece: piece,
                target: Coord(file: piece.file, rank: 3),
                canCapture: false
            ) {
                addMoveIfNotBlocked(
                    moves: &moves,
                    piece: piece,
                    target: Coord(file: piece.file, rank: 4),
                    canCapture: false
                )
            }

        case 3...7:  // can move only one square
            addMoveIfNotBlocked(
                moves: &moves,
                piece: piece,
                target: Coord(file: piece.file, rank: piece.rank + 1),
                canCapture: false, canPromote: piece.rank == 7
            )

        default: break
        }

        // capture
        addMoveIfNotBlocked(
            moves: &moves,
            piece: piece,
            target: Coord(file: piece.file + 1, rank: piece.rank + 1),
            canCapture: true, canPromote: piece.rank == 7,
            mustCapture: true
        )
        addMoveIfNotBlocked(
            moves: &moves,
            piece: piece,
            target: Coord(file: piece.file - 1, rank: piece.rank + 1),
            canCapture: true, canPromote: piece.rank == 7,
            mustCapture: true
        )

        // can capture en passant
        if let enPassantTarget = enPassantTarget,
           abs(piece.file - enPassantTarget.file) == 1,
           piece.rank == 5 {
            moves.append(
                Move(
                    piece: piece,
                    to: enPassantTarget,
                    captureTarget: pieces[Coord(file: enPassantTarget.file, rank: 5)]
                )
            )
        }

        // promotion is handled in the addMoveIfNotBlocked function
        return moves
    }

    private func getBlackPawnMoves(piece: ChessPiece) -> [Move] {
        var moves: [Move] = []

        // march 1 or 2 squares forward : rank decreases
        switch piece.rank {
        case 7:  // can move two squares
            if !addMoveIfNotBlocked(
                moves: &moves,
                piece: piece,
                target: Coord(file: piece.file, rank: 6),
                canCapture: false
            ) {
                addMoveIfNotBlocked(
                    moves: &moves,
                    piece: piece,
                    target: Coord(file: piece.file, rank: 5),
                    canCapture: false
                )
            }

        case 2...6:  // can move only one square
            addMoveIfNotBlocked(
                moves: &moves,
                piece: piece,
                target: Coord(file: piece.file, rank: piece.rank - 1),
                canCapture: false, canPromote: piece.rank == 2
            )

        default: break
        }

        // capture
        addMoveIfNotBlocked(
            moves: &moves,
            piece: piece,
            target: Coord(file: piece.file + 1, rank: piece.rank - 1),
            canCapture: true, canPromote: piece.rank == 2,
            mustCapture: true
        )
        addMoveIfNotBlocked(
            moves: &moves,
            piece: piece,
            target: Coord(file: piece.file - 1, rank: piece.rank - 1),
            canCapture: true, canPromote: piece.rank == 2,
            mustCapture: true
        )

        // can capture en passant
        if let enPassantTarget = enPassantTarget,
           abs(piece.file - enPassantTarget.file) == 1,
           piece.rank == 4 {
            moves.append(
                Move(
                    piece: piece,
                    to: enPassantTarget,
                    captureTarget: pieces[Coord(file: enPassantTarget.file, rank: 4)]
                )
            )
        }

        // promotion is handled in the addMoveIfNotBlocked function
        return moves
    }

}
