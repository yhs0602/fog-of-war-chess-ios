//
//  Piece.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/08.
//

import Foundation

enum ChessPieceType: String {
    case king, queen, rook, bishop, knight, pawn

    var shortName: Character {
        switch self {
        case .pawn: return " "
        case .rook: return "R"
        case .knight: return "N"
        case .bishop: return "B"
        case .queen: return "Q"
        case .king: return "K"
        }
    }

    var value: Int {
        switch self {
        case .pawn: return 1
        case .rook: return 5
        case .knight: return 3
        case .bishop: return 3
        case .queen: return 9
        case .king: return 1000
        }
    }
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
