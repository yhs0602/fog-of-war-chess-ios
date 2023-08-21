//
//  Models.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/16.
//

import Foundation

struct CreateRoomData: Codable {
    let color: String
    let fcmToken: String

    enum CodingKeys: String, CodingKey {
        case color
        case fcmToken = "fcm_token"
    }
}

struct JoinRoomData: Codable {
    let roomId: String
    let fcmToken: String

    enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case fcmToken = "fcm_token"
    }
}

struct GeneratedRoomInfo: Codable {
    let roomId: String
    let token: String

    enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case token
    }
}

struct JoinedRoomInfo: Codable {
    let roomId: String
    let token: String
    let boardState: BoardStateData

    enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case token
        case boardState = "board_state"
    }
}

struct MoveData: Codable {
    let fromPosition: String
    let toPosition: String
    let promotionPiece: String?

    enum CodingKeys: String, CodingKey {
        case fromPosition = "from_position"
        case toPosition = "to_position"
        case promotionPiece
    }
}

struct BoardStateData: Codable {
    let board: String
    let legalMoves: [MoveData]
    let status: String
    let winner: String?
    let fullMove: Int
    let color: String
    let roomId: String

    enum CodingKeys: String, CodingKey {
        case board
        case legalMoves = "legal_moves"
        case status
        case winner
        case fullMove = "full_move"
        case color
        case roomId = "room_id"
    }
}

struct BoardStateAndMoves {
    let boardState: BoardState
    let legalMoves: [MoveData]
    let color: ChessColor
}
