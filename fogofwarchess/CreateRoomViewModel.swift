//
//  CreateRoomViewModel.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/16.
//

import Combine
import SwiftUI

class CreateRoomViewModel: ObservableObject {
    @Published private var fcmToken: String? = UserDefaults.standard.fcmToken
    @Published var isWhite: Bool = true
    @Published var roomId: String = ""

    var cancellables = Set<AnyCancellable>()

    var canCreateRoom: AnyPublisher<Bool, Never> {
        return $fcmToken
            .map { $0 != nil }
            .eraseToAnyPublisher()
    }

    func prepareCreateRoom() {
        if fcmToken == nil {
            Task {
                do {
                    let token = try await fetchFCMToken()
                    UserDefaults.standard.fcmToken = token
                } catch {
                    print("An error occurred while fetching FCM token: \(error)")
                }
            }
        }
    }

    func createRoom() {
        guard let fcmToken = self.fcmToken else {
            return
        }
        Task {
            let roomData = try await ChessServiceImpl.shared.createRoom(
                data: CreateRoomData(
                    color: isWhite ? "white" : "black",
                    fcmToken: fcmToken
                )
            )
            await MainActor.run {
                self.roomId = roomData.roomId
            }
            UserDefaults.standard.set(roomData.token, forKey: "RoomToken")
        }
    }
}
