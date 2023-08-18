//
//  ChessServiceImpl.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/16.
//

import Foundation
import Moya

class ChessServiceImpl: ChessService {
    private init() {
    }

//    let networkLogger =
    let provider = MoyaProvider<ChessAPI>(plugins: [NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))]) // plugins: [networkLogger]

    func joinRoom(data: JoinRoomData) async throws -> JoinedRoomInfo {
        let result = await provider.request(.joinRoom(data: data))
        switch result {
        case .success(let response):
            let roomInfo = try JSONDecoder().decode(JoinedRoomInfo.self, from: response.data)
            print("Received room info: \(roomInfo)")
            return roomInfo
        case .failure(let error):
            print("Error calling the API: \(error)")
            throw error
        }
    }

    func applyMove(data: MoveData, token: String) async throws -> BoardStateData {
        let result = await provider.request(.applyMove(data: data, token: token))
        switch result {
        case .success(let response):
            let boardState = try JSONDecoder().decode(BoardStateData.self, from: response.data)
            print("Received room info: \(boardState)")
            return boardState
        case .failure(let error):
            print("Error calling the API: \(error)")
            throw error
        }
    }

    func createRoom(data: CreateRoomData) async throws -> GeneratedRoomInfo {
        print("Creating room with data color \(data.color) fcmtoken \(data.fcmToken)")
        let result = await provider.request(.createRoom(data: data))
        switch result {
        case .success(let response):
            let roomInfo = try JSONDecoder().decode(GeneratedRoomInfo.self, from: response.data)
            print("Received room info: \(roomInfo)")
            return roomInfo
        case .failure(let error):
            print("Error calling the API: \(error)")
            throw error
        }
    }
}

extension ChessServiceImpl {
    static let shared: ChessService = ChessServiceImpl()
}
