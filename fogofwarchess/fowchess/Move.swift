//
//  Move.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/08.
//

import Foundation

class Move {
    let piece: ChessPiece
    let to: Coord
    let castlingRook: ChessPiece?
    let promotingTo: ChessPieceType?
    let captureTarget: ChessPiece?

    init(piece: ChessPiece, to: Coord, captureTarget: ChessPiece? = nil, castlingRook: ChessPiece? = nil, promotingTo: ChessPieceType? = nil) {
        self.piece = piece
        self.to = to
        self.castlingRook = castlingRook
        self.promotingTo = promotingTo
        self.captureTarget = captureTarget
    }
}
