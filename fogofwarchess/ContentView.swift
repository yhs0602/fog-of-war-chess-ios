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
            }
        }.onTapGesture {
            cellTapped(row, column)
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()

    var chessBoard: some View {
        VStack {
            GeometryReader { geometry in
                let squareSize = min(geometry.size.width, geometry.size.height) / 9
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
                }
            }
            Text("Current turn: \(viewModel.currentColor.rawValue)")
            Text("Selected Piece: \(viewModel.selectedPiece?.description ?? "None")")
            Text("History: \(viewModel.historyPgn)")
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
