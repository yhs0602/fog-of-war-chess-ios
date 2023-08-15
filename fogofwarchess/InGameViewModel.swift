//
//  ContentViewModel.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/08.
//

import Foundation
import SwiftUI
import AVFoundation
import Combine

enum GamePhase: String {
    case playing, white_win, black_win
}

class InGameViewModel: ObservableObject {
    var dropAudioPlayer: AVAudioPlayer?
    var placeAudioPlayer: AVAudioPlayer?

    let serverType: ServerType
    var roomId: String?
    private var server: ChessServer

    @Published var possibleMoves: [ChessPiece: [Move]] = [:]
    @Published var board: BoardState = BoardState.EmptyBoardState
    @Published private(set) var selectedPiece: ChessPiece?
    @Published var promotingMove: Move?
    @Published private(set) var isNextTurnEnabled: Bool = false
    @Published var winner: ChessColor?
    private var disposables = Set<AnyCancellable>()

    init(
        serverType: ServerType,
        roomId: String?
    ) {
        self.selectedPiece = nil
        self.possibleMoves = [:]
        self.serverType = serverType
        self.roomId = roomId
        switch serverType {
        case .singlePlay:
            server = SinglePlayChessServer()
        case .passNPlay:
            server = PassNPlayChessServer()
        case .remote:
            server = RemoteChessServer()
        }
        bindOutputs()
        setupAudioPlayer()
    }

    func bindOutputs() {
        server.possibleMoves
            .receive(on: RunLoop.main)
            .assign(to: \.possibleMoves, on: self)
            .store(in: &disposables)

        server.fen
            .map { fen in
                let board = FenParser(fenStr: fen, fowMark: "U").parse()
            return board
        }
            .receive(on: RunLoop.main)
            .assign(to: \.board, on: self)
            .store(in: &disposables)

        server.winner
            .receive(on: RunLoop.main)
            .assign(to: \.winner, on: self)
            .store(in: &disposables)

    }

    var selectedPossibleMoves: [Move] {
        guard let selectedPiece else {
            return []
        }
        return possibleMoves[selectedPiece, default: []]
    }

    func setupAudioPlayer() {
        if let audioURL = Bundle.main.url(forResource: "drop", withExtension: "mp3") {
            do {
                dropAudioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            } catch {
                print("Error loading audio: \(error)")
            }
        } else {
            print("Cannot find audio")
        }
        if let audioURL = Bundle.main.url(forResource: "place", withExtension: "mp3") {
            do {
                placeAudioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            } catch {
                print("Error loading audio: \(error)")
            }
        } else {
            print("Cannot find audio 2")
        }
    }

    func cellTapped(coord: Coord) {
        if selectedPiece == nil {
            selectPiece(coord: coord)
        } else if let move = selectedPossibleMoves.first(where: { $0.to == coord }) {
            movePiece(move: move)
        } else {
            selectPiece(coord: coord)
        }
    }

    private func selectPiece(coord: Coord) {
        if winner != nil {
            return
        }

        if let piece = board.pieces[coord], piece.color == board.turn {
            selectedPiece = piece
        } else {
            selectedPiece = nil
        }
    }

    private func movePiece(move: Move) {
        if !selectedPossibleMoves.contains(move) {
            // Invalid move
            print("Invalid move")
            return
        }

        if move.shouldPromote() {
            promotingMove = move
            selectedPiece = nil
            return
        } else {
            promotingMove = nil
        }

        do {
            try server.applyMove(move: move)
            if case .passNPlay = serverType {
                isNextTurnEnabled = true
            }
        } catch {
            // Invalid move
            return
        }

        // Valid move, update the current turn
        selectedPiece = nil
    }


    func promotePiece(toType: ChessPieceType) {
        guard let move = promotingMove else { return }

        do {
            try server.applyMove(
                move: Move(
                    piece: move.piece,
                    to: move.to,
                    captureTarget: move.captureTarget,
                    promotingTo: toType
                )
            )
            promotingMove = nil
            if case .passNPlay = serverType {
                isNextTurnEnabled = true
            }
        } catch {
            // Invalid move
            return
        }

        // Valid move, update the current turn
    }

    func reset(playerColor: ChessColor) {
        server.resetGame(playerColor: playerColor)
        selectedPiece = nil
        promotingMove = nil
    }


    func nextTurn() {
        server.onNextTurnStart()
    }

//    var historyPgn: String {
//        let history = board.moveHistory
//        var foldedHistory: [Move] = []
//        var shouldSkip = false
//
//        for i in history.indices {
//            if shouldSkip {
//                shouldSkip = false
//                continue
//            }
//
//            let move = history[i]
//
//            if move.promotingTo == .pawn, i + 1 < history.count {
//                let promotingMove = history[i + 1]
//                let newMove = Move(
//                    piece: move.piece,
//                    to: move.to,
//                    promotingTo: promotingMove.promotingTo
//                )
//                foldedHistory.append(newMove)
//                shouldSkip = true
//            } else {
//                foldedHistory.append(move)
//            }
//        }
//
//        let historyString = foldedHistory.enumerated().map { (index, move) -> String in
//            let prefix = move.piece.color == .black ? "..." : "."
//            if index % 2 == 0 {
//                return "\(index / 2 + 1)\(prefix)\(move.getPgn(board: board))"
//            } else {
//                return prefix + move.getPgn(board: board)
//            }
//        }.joined(separator: " ")
//        return historyString
//    }
}
