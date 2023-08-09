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
    let captureTarget: ChessPiece? = nil

    init(piece: ChessPiece, from: Coord, to: Coord, captureTarget: ChessPiece? = nil) {
        self.piece = piece
        self.from = from
        self.to = to
    }
}
