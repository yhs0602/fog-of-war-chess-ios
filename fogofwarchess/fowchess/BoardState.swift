//
//  BoardState.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/15.
//

import Foundation

struct BoardState {
    let pieces: [Coord: ChessPiece]
    let turn: ChessColor
    let castling: [ChessColor: [Bool]]
    let enPassantTarget: Coord?
    let halfMoveClock: Int
    let fullMoveNumber: Int
    let coordVisibility: [Coord: Bool]

    static let DefaultFen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

    init(
        pieces: [Coord: ChessPiece],
        turn: ChessColor,
        castling: [ChessColor: [Bool]],
        enPassantTarget: Coord?,
        halfMoveClock: Int,
        fullMoveNumber: Int,
        coordVisibility: [Coord: Bool] = [:]
    ) {
        self.pieces = pieces
        self.turn = turn
        self.castling = castling
        self.enPassantTarget = enPassantTarget
        self.halfMoveClock = halfMoveClock
        self.fullMoveNumber = fullMoveNumber
        self.coordVisibility = coordVisibility
    }

    static func applyMove(_ board: BoardState, _ move: Move) -> (BoardState, ChessColor?) {
        var pieces = board.pieces
        var castling = board.castling

        pieces.removeValue(forKey: move.piece.pos)

        if let captureTarget = move.captureTarget {
            pieces.removeValue(forKey: captureTarget.pos)
        }

        let enPassant: Coord? = (move.piece.type == .pawn && abs(move.piece.rank - move.to.rank) == 2)
            ? (move.piece.color == .black ? Coord(file: move.piece.file, rank: move.piece.rank - 1)
        : Coord(file: move.piece.file, rank: move.piece.rank + 1))
        : nil

        let newPiece = ChessPiece(
            type: move.promotingTo ?? move.piece.type, color: move.piece.color, pos: move.to
        )
        pieces[move.to] = newPiece

        // Handle castling.
        if let rook = move.castlingRook {
            pieces[rook.pos] = nil

            var newRookPosition: Coord
            switch move.to {
            case Coord(file: 3, rank: 8):
                newRookPosition = Coord(file: 4, rank: 8)
            case Coord(file: 7, rank: 8):
                newRookPosition = Coord(file: 6, rank: 8)
            case Coord(file: 3, rank: 1):
                newRookPosition = Coord(file: 4, rank: 1)
            default:
                newRookPosition = Coord(file: 6, rank: 1)
            }

            pieces[newRookPosition] = ChessPiece(type: rook.type, color: rook.color, pos: newRookPosition)
        }

        // Update castling rights if needed.
        if move.piece.type == .rook || move.piece.type == .king {
            let color = move.piece.color
            switch (move.piece.rank, move.piece.file) {
            case (8, 1):
                castling[color] = [false, castling[color]?[1] ?? true]
            case (8, 8):
                castling[color] = [castling[color]?[0] ?? true, false]
            case (1, 1):
                castling[color] = [false, castling[color]?[1] ?? true]
            case (1, 8):
                castling[color] = [castling[color]?[0] ?? true, false]
            default:
                break
            }

            if move.piece.type == .king {
                castling[color] = [false, false]
            }
        }

        let sideToMove: ChessColor = (board.turn == .black) ? .white : .black
        let fullMoveNumber: Int = (sideToMove == .white) ? board.fullMoveNumber + 1 : board.fullMoveNumber
        let halfMoveClock: Int = (move.piece.type == .pawn || move.captureTarget != nil) ? 0 : board.halfMoveClock + 1

        let winner: ChessColor? = (move.captureTarget?.type == .king) ? move.piece.color : nil

        let newBoardState = BoardState(pieces: pieces, turn: sideToMove, castling: castling, enPassantTarget: enPassant, halfMoveClock: halfMoveClock, fullMoveNumber: fullMoveNumber)

        return (newBoardState, winner)
    }

    static let EmptyBoardState = BoardState(
        pieces: [:],
        turn: .white,
        castling: [
                .white: [true, true],
                .black: [true, true]
        ],
        enPassantTarget: nil,
        halfMoveClock: 0,
        fullMoveNumber: 1
    )

    func toFen() -> String {
        // Generate the piece placement string
        var ranks: [String] = []
        for rank in (1...8).reversed() {
            var emptyCounter = 0
            var rankStr = ""
            for file in 1...8 {
                let position = Coord(file: file, rank: rank)
                if let piece = pieces[position] {
                    if emptyCounter > 0 {
                        rankStr += String(emptyCounter)
                        emptyCounter = 0
                    }
                    rankStr += piece.color == .white ? piece.type.shortName.uppercased() : piece.type.shortName.lowercased()
                } else {
                    emptyCounter += 1
                }
            }
            if emptyCounter > 0 {
                rankStr += String(emptyCounter)
            }
            ranks.append(rankStr)
        }

        // Determine side to move
        let sideToMove = turn == .white ? "w" : "b"

        // Determine castling rights
        var castlingStr = ""
        if castling[.white]?[0] == true { castlingStr += "K" }
        if castling[.white]?[1] == true { castlingStr += "Q" }
        if castling[.black]?[0] == true { castlingStr += "k" }
        if castling[.black]?[1] == true { castlingStr += "q" }
        if castlingStr.isEmpty { castlingStr = "-" }

        // Determine en passant target square
        let enPassantStr = enPassantTarget?.coordCode ?? "-"

        // Convert the attributes to FEN format
        let fen = [ranks.joined(separator: "/"), sideToMove, castlingStr, enPassantStr, String(halfMoveClock), String(fullMoveNumber)].joined(separator: " ")

        return fen
    }

    func toFowFen(color: ChessColor) -> String {
        // Get possible moves to get sight
        let possibleMoves = getLegalMoves(color: color)

        // Calculate the sight
        var sight = Set<Coord>()
        pieces.values.filter { $0.color == color }
            .forEach { sight.insert($0.pos) }
        possibleMoves.forEach { (_, moves) in
            moves.forEach { move in
                sight.insert(move.to)
            }
        }

        // Generate the piece placement string
        var ranks: [String] = []
        for rank in (1...8).reversed() {
            var emptyCounter = 0
            var rankStr = ""
            for file in 1...8 {
                let position = Coord(file: file, rank: rank)
                let piece = pieces[position]
                if sight.contains(position) {
                    if let piece = piece {
                        if emptyCounter > 0 {
                            rankStr += String(emptyCounter)
                            emptyCounter = 0
                        }
                        rankStr += piece.color == .white ? piece.type.shortName.uppercased() : piece.type.shortName.lowercased()
                    } else {
                        emptyCounter += 1
                    }
                } else {
                    if emptyCounter > 0 {
                        rankStr += String(emptyCounter)
                        emptyCounter = 0
                    }
                    rankStr += "U"
                }
            }
            if emptyCounter > 0 {
                rankStr += String(emptyCounter)
            }
            ranks.append(rankStr)
        }

        // Determine side to move
        let sideToMove = turn == .white ? "w" : "b"

        // Determine castling rights
        var castlingStr = ""
        if color == .white {
            if castling[.white]?[0] == true { castlingStr += "K" }
            if castling[.white]?[1] == true { castlingStr += "Q" }
        } else {
            if castling[.black]?[0] == true { castlingStr += "k" }
            if castling[.black]?[1] == true { castlingStr += "q" }
        }
        if castlingStr.isEmpty { castlingStr = "-" }

        // Determine en passant target square
        let enPassantStr = (enPassantTarget != nil && sight.contains(enPassantTarget!)) ? enPassantTarget!.coordCode : "-"

        // Convert the attributes to FEN format
        let fen = [ranks.joined(separator: "/"), sideToMove, castlingStr, enPassantStr, "0", String(fullMoveNumber)].joined(separator: " ")

        return fen
    }

    func toFowBoard(color: ChessColor) -> BoardState {
        print("toFowBoard \(color.rawValue)")
        let newPieces = pieces // TODO: Hide castling rights of the opponent
        let newCastling = castling
        // Get possible moves to get sight
        let possibleMoves = getLegalMoves(color: color)
        print("getLegalMoves \(color.rawValue)")
        // Calculate the sight
        var sight = Set<Coord>()
        newPieces.values.filter { $0.color == color }
            .forEach { sight.insert($0.pos) }
        possibleMoves.forEach { (_, moves) in
            moves.forEach { move in
                sight.insert(move.to)
            }
        }
        print("Got sight: \(sight)")

        let filteredPieces = newPieces.filter { sight.contains($0.key) }
        let coordVisibility = Dictionary(uniqueKeysWithValues: sight.map { ($0, true) })

        return BoardState(
            pieces: filteredPieces,
            turn: turn,
            castling: newCastling,
            enPassantTarget: enPassantTarget,
            halfMoveClock: halfMoveClock,
            fullMoveNumber: fullMoveNumber,
            coordVisibility: coordVisibility
        )
    }

    func getLegalMoves(color: ChessColor) -> [ChessPiece: [Move]] {
        var legalMoves = [ChessPiece: [Move]]()

        for (_, piece) in pieces {
            if piece.color == color {
                let moves: [Move]
                switch piece.type {
                case .pawn:
                    moves = getPawnMoves(piece: piece)
                case .knight:
                    moves = getKnightMoves(piece: piece)
                case .bishop:
                    moves = getBishopMoves(piece: piece)
                case .rook:
                    moves = getRookMoves(piece: piece)
                case .queen:
                    moves = getQueenMoves(piece: piece)
                case .king:
                    moves = getKingMoves(piece: piece)
                }

                if !moves.isEmpty {
                    legalMoves[piece] = moves
                }
            }
        }

        return legalMoves
    }
}
