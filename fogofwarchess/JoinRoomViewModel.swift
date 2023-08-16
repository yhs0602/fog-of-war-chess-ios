//
//  JoinRoomViewModel.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/17.
//

import Combine
import SwiftUI

class JoinRoomViewModel: ObservableObject {
    @Published private var fcmToken: String? = UserDefaults.standard.fcmToken
    @Published var roomId: String = ""
    @Published var canJoinRoom: Bool = false

    var cancellables = Set<AnyCancellable>()

    var canJoinRoomPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest($fcmToken, $roomId)
            .map { fcmToken, roomId in
                return fcmToken != nil && !roomId.isEmpty
            }.eraseToAnyPublisher()
    }

    init() {
        bindOutputs()
    }

    func bindOutputs() {
        canJoinRoomPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.canJoinRoom, on: self)
            .store(in: &cancellables)
    }

    func prepareJoinRoom() {
        print("prepareJoinRoom called")
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

    func joinRoom() {
        guard let fcmToken = self.fcmToken else {
            return
        }
        Task {
            let roomData = try await ChessServiceImpl.shared.joinRoom(
                data: JoinRoomData(
                    roomId: roomId,
                    fcmToken: fcmToken
                )
            )
            UserDefaults.standard.roomToken = roomData.token
            // TODO: Navigate to the game screen
        }
    }
}
