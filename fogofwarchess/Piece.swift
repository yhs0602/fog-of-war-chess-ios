//
//  Piece.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/08.
//

import Foundation

enum ChessPieceType: String {
    case king, queen, rook, bishop, knight, pawn
}

class ChessPiece: CustomStringConvertible {
    let type: ChessPieceType
    let color: ChessColor
    // Coordinates managed by the Board
    var pos: Coord
    var row: Int {
        return pos.row
    }
    var column: Int {
        return pos.column
    }

    init(type: ChessPieceType, color: ChessColor, pos: Coord) {
        self.type = type
        self.color = color
        self.pos = pos
    }

    var description: String {
        return "\(color) \(type) at \(pos.coordCode)"
    }
}
