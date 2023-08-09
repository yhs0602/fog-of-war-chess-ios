//
//  Move.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/08.
//

import Foundation

class Move {
    let piece: ChessPiece
    let from: Coord
    let to: Coord
    let castlingRook: ChessPiece?
    let promotingTo: ChessPieceType?
    let captureTarget: ChessPiece?
    let board: [ChessPiece]

    init(board: [ChessPiece], piece: ChessPiece, from: Coord, to: Coord, captureTarget: ChessPiece? = nil, castlingRook: ChessPiece? = nil, promotingTo: ChessPieceType? = nil) {
        self.board = board
        self.piece = piece
        self.from = from
        self.to = to
        self.castlingRook = castlingRook
        self.promotingTo = promotingTo
        self.captureTarget = captureTarget
    }
}
