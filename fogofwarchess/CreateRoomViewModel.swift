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
    @Published var canCreateRoom: Bool = false

    var cancellables = Set<AnyCancellable>()

    var canCreateRoomPublisher: AnyPublisher<Bool, Never> {
        return $fcmToken
            .map { $0 != nil }
            .eraseToAnyPublisher()
    }

    init() {
        bindOutputs()
    }

    func bindOutputs() {
        canCreateRoomPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.canCreateRoom, on: self)
            .store(in: &cancellables)
    }

    func prepareCreateRoom() {
        print("prepareCreateRoom called")
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
        RemoteChessServer.shared.resetGame(playerColor: .white)
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
            UserDefaults.standard.roomToken = roomData.token
        }
    }
}
