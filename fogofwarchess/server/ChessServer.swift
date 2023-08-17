//
//  ChessServer.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/15.
//
import Combine

protocol ChessServer {

    // A function that mimics Kotlin's suspend function. In Swift, we might use a completion handler
    // or a Combine Publisher to achieve similar effects. Here, we use a Future as it represents a
    // single value that will be produced sometime in the future.
    func applyMove(move: Move) async

    func resetGame(playerColor: ChessColor)

    func onNextTurnStart()

    // Combine's `Publisher` to notify changes, equivalent to Kotlin's `Flow`
    var fen: AnyPublisher<String, Never> { get }

    // Combine's `Publisher` to notify changes, equivalent to Kotlin's `Flow`
    var possibleMoves: AnyPublisher<[ChessPiece: [Move]], Never> { get }

    // Combine's `Publisher` to notify changes, equivalent to Kotlin's `Flow`
    var winner: AnyPublisher<ChessColor?, Never> { get }
}
