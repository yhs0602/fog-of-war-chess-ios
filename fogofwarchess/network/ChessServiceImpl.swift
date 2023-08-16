//
//  ChessServiceImpl.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/16.
//

import Foundation

class ChessServiceImpl: ChessService {
    func joinRoom(data: JoinRoomData) async throws -> GeneratedRoomInfo {
        <#code#>
    }

    func applyMove(data: MoveData, token: String) async throws -> BoardState {
        <#code#>
    }


    let baseURL = URL(string: "https://prod-y6lhqx6yia-du.a.run.app/")!
    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func createRoom(data: CreateRoomData) async throws -> GeneratedRoomInfo {
        let url = baseURL.appendingPathComponent("create-room")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let jsonData = try JSONEncoder().encode(data)
        request.httpBody = jsonData

        let (data, _) = try await session.data(for: request)
        let result = try JSONDecoder().decode(GeneratedRoomInfo.self, from: data)

        return result
    }

    // ... similarly for other methods
}

extension ChessServiceImpl {
    static let shared: ChessService = ChessServiceImpl(session: .shared)
}

