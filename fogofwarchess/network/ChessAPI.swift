//
//  ChessAPI.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/16.
//

import Foundation
import Moya

enum ChessAPI {
    case createRoom(data: CreateRoomData)
    case joinRoom(data: JoinRoomData)
    case applyMove(data: MoveData, token: String)
}

extension ChessAPI: TargetType {

    var baseURL: URL {
        return URL(string: "https://prod-y6lhqx6yia-du.a.run.app")!
    }

    var path: String {
        switch self {
        case .createRoom:
            return "/create-room"
        case .joinRoom:
            return "/join-room"
        case .applyMove:
            return "/apply-move"
        }
    }

    var method: Moya.Method {
        switch self {
        case .createRoom, .joinRoom, .applyMove:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .createRoom(let data):
            return .requestJSONEncodable(data)
        case .joinRoom(let data):
            return .requestJSONEncodable(data)
        case .applyMove(let data, _):
            return .requestJSONEncodable(data)
        }
    }

    var headers: [String: String]? {
        var headers = ["Content-Type": "application/json"]

        switch self {
        case .applyMove(_, let token): // Use the token parameter
            headers["Authorization"] = "Bearer \(token)" // Add the Authorization header with token
        default:
            break // No additional headers for other cases
        }

        return headers
    }
}
