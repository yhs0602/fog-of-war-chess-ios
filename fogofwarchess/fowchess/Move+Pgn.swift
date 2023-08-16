//
//  Move+Pgn.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/09.
//

import Foundation

extension Move {
//    func checkPawnInColumn(pawn: ChessPiece, board: [ChessPiece]) -> Bool {
//        if pawn.type != .pawn {
//            return false
//        }
//
//        for i in 0...7 {
//            if board.first(where: {
//                $0.column == pawn.column && $0.row == i && $0.type == .pawn && $0 !== pawn && $0.color == pawn.color
//            }) != nil {
//                return true
//            }
//        }
//
//        return false
//    }

//    func getPgn() -> String {
//        var sb = ""
//
//        if piece.type == .pawn {
//            if captureTarget != nil {
//                if checkPawnInColumn(pawn: piece, board: self.board) {
//                    sb.append(from.coordCode)
//                } else {
//                    sb.append(from.coordLetter)
//                }
//                sb.append("x")
//                sb.append(to.coordCode)
//            } else {
//                sb.append(to.coordCode)
//            }
//            if let promotingTo = promotingTo {
//                sb.append("=")
//                sb.append(promotingTo.shortName)
//            }
//        } else if let castlingRook = castlingRook {
//            if castlingRook.column == 0 {
//                sb.append("O-O-O")
//            } else {
//                sb.append("O-O")
//            }
//        } else {
//            sb.append(piece.type.shortName)
//            let ambiguousPieces = self.board.filter {
//                piece.type == $0.type && piece.color == $0.color && piece !== $0
//            }.filter {
//                let moves = board.getPossibleMovesWithoutPawn(piece: $0)
//                return moves.contains { move in move.to == to }
//            }
//            if !ambiguousPieces.isEmpty {
//                let ambiguousPiles = ambiguousPieces.filter {
//                    piece.column == $0.column
//                }
//                if ambiguousPiles.isEmpty {
//                    sb.append(from.coordLetter)
//                } else {
//                    let ambiguousRanks = ambiguousPiles.filter {
//                        piece.row == $0.row
//                    }
//                    if ambiguousRanks.isEmpty {
//                        sb.append(from.coordNumber)
//                    } else {
//                        sb.append(from.coordCode)
//                    }
//                }
//            }
//            if captureTarget != nil {
//                sb.append("x")
//            }
//            sb.append(to.coordCode)
//            if captureTarget?.type == .king {
//                sb.append("#")
//            }
//        }
//        return sb
//    }
}
