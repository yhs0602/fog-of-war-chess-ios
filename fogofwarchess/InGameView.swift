//
//  ContentView.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/08.
//

import SwiftUI

extension Color {
    static let ivory = Color(red: 255 / 255, green: 255 / 255, blue: 240 / 255)
}

struct InGameView: View {
    let color: ChessColor?
    let shouldReset: Bool
    let serverType: ServerType
    let roomId: String?

    @StateObject private var viewModel: InGameViewModel

    init(color: ChessColor?, shouldReset: Bool, serverType: ServerType, roomId: String? = nil) {
        self.color = color
        self.shouldReset = shouldReset
        self.serverType = serverType
        self.roomId = roomId
        self._viewModel = StateObject(
            wrappedValue: InGameViewModel(serverType: serverType, roomId: roomId)
        )
    }

    var chessBoard: some View {
        GeometryReader { geometry in
            let board = viewModel.board
            let squareSize = min(geometry.size.width, geometry.size.height) / 8
            VStack {
                HStack(spacing: 0) {
                    ForEach(0..<8 as Range<Int>) { file in
                        VStack(spacing: 0) {
                            ForEach(0..<8 as Range<Int>) { (rank) -> CellView in
                                let coord = Coord(file: file + 1, rank: rank + 1)
                                CellView(
                                    squareSize: squareSize,
                                    coord: coord,
                                    piece: board.pieces[coord],
                                    visible: board.coordVisibility[coord] == true,
                                    hasMove: viewModel.selectedPossibleMoves.contains { move in
                                        move.to == coord
                                    },
                                    cellTapped: viewModel.cellTapped
                                )
                            }
                        }
                    }
                }.border(.black)
                Text("Current turn: \(board.turn.rawValue)")
                Text("Selected Piece: \(viewModel.selectedPiece?.description ?? "None")")
//                if viewModel.gamePhase != .playing {
//                    Text("History: \(viewModel.historyPgn)")
//                    Button("Copy PGN") {
//                        let pgn = viewModel.historyPgn
//                        let pasteboard = UIPasteboard.general
//                        pasteboard.string = pgn
//                    }
//                }
//                Text("Game phase: \(board.)")
//                Button("Reset") {
//                    viewModel.reset()
//                }
                NavigationLink(destination: TurnCoverView(color: board.turn, shouldReset: false)) {
                    Text("Next Turn")
                }
            }
        }.border(.black)
            .confirmationDialog("Select a color", isPresented: Binding<Bool>(
            get: { viewModel.promotingMove != nil },
            set: { _ in viewModel.promotingMove = nil }
        ), titleVisibility: .visible) {
            Button("Queen") {
                viewModel.promotePiece(toType: .queen)
            }
            Button("Rook") {
                viewModel.promotePiece(toType: .rook)
            }
            Button("Bishop") {
                viewModel.promotePiece(toType: .bishop)
            }
            Button("Knight") {
                viewModel.promotePiece(toType: .knight)
            }
        }
    }
    var body: some View {
        chessBoard.onAppear {
            print("Color: \(color) shouldReset: \(shouldReset)")
            if let color { // pass and play or singleplay
                if shouldReset {
                    viewModel.reset(playerColor: color)
                } else {
                    viewModel.nextTurn()
                }
            }
        }
    }
}

struct CellView: View {
    let squareSize: CGFloat
    let coord: Coord
    let piece: ChessPiece?
    let visible: Bool
    let hasMove: Bool
    let cellTapped: (Coord) -> Void

    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: squareSize, height: squareSize)
                .foregroundColor(
                visible ? coord.color : .gray
            )

            if let piece, visible {
                Image(piece.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            if hasMove {
                Text("x")
                    .foregroundColor(.red)
            }
        }.frame(width: squareSize, height: squareSize)
            .onTapGesture {
            if visible {
                cellTapped(coord)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        InGameView(
            color: .white,
            shouldReset: false,
            serverType: .singlePlay
        )
    }
}
