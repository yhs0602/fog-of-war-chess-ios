//
//  ChessService.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/16.
//

import Foundation

protocol ChessService {
    func createRoom(data: CreateRoomData) async throws -> GeneratedRoomInfo
    func joinRoom(data: JoinRoomData) async throws -> JoinedRoomInfo
    func applyMove(data: MoveData, token: String) async throws -> BoardStateData
}
