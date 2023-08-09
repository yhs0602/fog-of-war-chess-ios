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

struct CellView: View {
    let squareSize: CGFloat
    let row: Int
    let column: Int
    let cellTapped: (Int, Int) -> Void
    let piece: ChessPiece?
    let move: Move?
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: squareSize, height: squareSize)
                .foregroundColor((row + column) % 2 == 0 ? .ivory : .teal)

            if let piece {
                Image(piece.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            if move != nil {
                Text("x")
                    .foregroundColor(.red)
            }
        }.frame(width: squareSize, height: squareSize)
            .onTapGesture {
            cellTapped(row, column)
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()

    var chessBoard: some View {
        GeometryReader { geometry in
            VStack {
                let squareSize = min(geometry.size.width, geometry.size.height) / 8
                HStack(spacing: 0) {
                    ForEach(0..<8) { i in
                        VStack(spacing: 0) {
                            ForEach(0..<8) { j in
                                CellView(
                                    squareSize: squareSize,
                                    row: j,
                                    column: i,
                                    cellTapped: viewModel.cellTapped,
                                    piece: viewModel.pieceAt(row: j, column: i),
                                    move: viewModel.moveAt(row: j, column: i)
                                )
                            }
                        }
                    }
                }.border(.black)
                Text("Current turn: \(viewModel.currentColor.rawValue)")
                Text("Selected Piece: \(viewModel.selectedPiece?.description ?? "None")")
                Text("History: \(viewModel.historyPgn)")
                Text("Game phase: \(viewModel.gamePhase.rawValue)")
            }
        }.border(.black)
            .confirmationDialog("Select a color", isPresented: Binding<Bool>(
            get: { viewModel.promotingPawn != nil },
            set: { _ in viewModel.promotingPawn = nil }
        ), titleVisibility: .visible) {
            Button("Queen") {
                viewModel.promote(pieceType: .queen)
            }

            Button("Rook") {
                viewModel.promote(pieceType: .rook)
            }

            Button("Bishop") {
                viewModel.promote(pieceType: .bishop)
            }
            Button("Knight") {
                viewModel.promote(pieceType: .knight)
            }
        }
    }
    var body: some View {
        chessBoard
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
