//
//  FenParser.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/15.
//

import Foundation

struct FenParser {
    let fenStr: String
    let fowMark: String

    func parse() -> BoardState {
        let parts = fenStr.split(separator: " ")
        let placement = parts[0]
        let sideToMove = parts[1]
        let castling = parts[2]
        let enPassant = parts[3]
        let halfmoveClock = Int(parts[4])!
        let fullmoveNumber = Int(parts[5])!
        let ranks = placement.split(separator: "/")
        let piecesOnAllRanks = ranks.map { parseRank(rank: String($0)) }

        var castlingParsed: [ChessColor: [Bool]] = [
                .white: ["K" ∈ String(castling), "Q" ∈ String(castling)],
                .black: ["k" ∈ String(castling), "q" ∈ String(castling)]
        ]

        let parsedEnPassant: Coord?
        if enPassant != "-" {
            parsedEnPassant = Coord(san: String(enPassant)) // file: Int(file), rank: rank
        } else {
            parsedEnPassant = nil
        }

        let parsedSideToMove: ChessColor = (sideToMove == "w") ? .white : .black

        var pieces: [Coord: ChessPiece] = [:]
        var coordVisibility: [Coord: Bool] = [:]

        for rank in 1...8 {
            for file in 1...8 {
                let pieceChar = piecesOnAllRanks[8 - rank][file - 1]
                let coord = Coord(file: file, rank: rank)
                switch pieceChar {
                case " ":
                    coordVisibility[coord] = true
                case Character(fowMark):
                    coordVisibility[coord] = false
                default:
                    coordVisibility[coord] = true
                    pieces[coord] = ChessPiece(pieceChar: pieceChar, coord: coord)
                }
            }
        }

        return BoardState(
            pieces: pieces,
            turn: parsedSideToMove,
            castling: castlingParsed,
            enPassantTarget: parsedEnPassant,
            halfMoveClock: halfmoveClock,
            fullMoveNumber: fullmoveNumber,
            coordVisibility: coordVisibility
        )
    }

    private func parseRank(rank: String) -> [Character] {
        let rankRe = try! NSRegularExpression(pattern: "([1-8]|[kqbnrpKQBNRP\(fowMark)])")
        let pieceTokens = rankRe.matches(in: rank, range: NSRange(rank.startIndex..., in: rank)).map {
            rank[Range($0.range, in: rank)!].first!
        }
        return pieceTokens.flatMap {
            expandOrNoop(pieceStr: $0)
        }
    }

    private func expandOrNoop(pieceStr: Character) -> [Character] {
        if "kqbnrpKQBNRP\(fowMark)".contains(pieceStr) {
            return [pieceStr]
        } else {
            return expand(numChr: pieceStr)
        }
    }

    private func expand(numChr: Character) -> [Character] {
        return Array(repeating: " ", count: Int(String(numChr))!)
    }
}

infix operator ∈
extension Character {
    static func ∈(lhs: Character, rhs: String) -> Bool {
        return rhs.contains(lhs)
    }
}
