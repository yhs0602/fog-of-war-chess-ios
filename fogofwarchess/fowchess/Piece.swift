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
        case .pawn: return "P"
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

    var darkResource: String {
        switch self {
        case .pawn: return "pdt"
        case .rook: return "rdt"
        case .knight: return "ndt"
        case .bishop: return "bdt"
        case .queen: return "qdt"
        case .king: return "kdt"
        }
    }

    var lightResource: String {
        switch self {
        case .pawn: return "plt"
        case .rook: return "rlt"
        case .knight: return "nlt"
        case .bishop: return "blt"
        case .queen: return "qlt"
        case .king: return "klt"
        }
    }

    static func fromShortName(_ shortName: Character) -> ChessPieceType? {
        switch shortName {
        case "P": return .pawn
        case "R": return .rook
        case "N": return .knight
        case "B": return .bishop
        case "Q": return .queen
        case "K": return .king
        default: return nil
        }
    }
}

class ChessPiece: CustomStringConvertible, Hashable {
    let type: ChessPieceType
    let color: ChessColor
    // Coordinates managed by the Board
    let pos: Coord
    let moved: Bool
    var rank: Int {
        return pos.rank
    }
    var file: Int {
        return pos.file
    }

    var image: String {
        if color == .black {
            return type.darkResource
        } else {
            return type.lightResource
        }
    }

    init(type: ChessPieceType, color: ChessColor, pos: Coord, moved: Bool = false) {
        self.type = type
        self.color = color
        self.pos = pos
        self.moved = moved
    }

    init(pieceChar: Character, coord: Coord) {
        self.pos = coord
        if pieceChar.isUppercase {
            self.color = .white
        } else {
            self.color = .black
        }
        self.type = ChessPieceType.fromShortName(Character(String(pieceChar).uppercased())) ?? .pawn
        self.moved = false
    }

    var description: String {
        return "\(color) \(type) at \(pos.coordCode)"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(color)
        hasher.combine(pos)
        hasher.combine(moved)
    }

    static func == (lhs: ChessPiece, rhs: ChessPiece) -> Bool {
        return lhs.type == rhs.type &&
            lhs.color == rhs.color &&
            lhs.pos == rhs.pos &&
            lhs.moved == rhs.moved
    }
}
