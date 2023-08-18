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
        print("JoinRoom")
        guard let fcmToken = self.fcmToken else {
            print("Fcm token is nil")
            return
        }
        RemoteChessServer.shared.resetGame(playerColor: .white) // Just instantiate the Remote Chess server
        Task {
            do {
                let roomData = try await ChessServiceImpl.shared.joinRoom(
                    data: JoinRoomData(
                        roomId: roomId,
                        fcmToken: fcmToken
                    )
                )
                print("Will save")
                UserDefaults.standard.roomToken = roomData.token
                print("Joined room: \(roomData.token)")
                let boardState = roomData.boardState
                // Emit to the remote Server.
                JoinRoomResultManager.shared.joinRoomResultBoardState.send(boardState)
                print("Sent joinRoomResultBoardState: \(boardState)")
                // Navigate to the game screen
                await MainActor.run {
                    let navigationManager = NavigationStateManager.shared
                    navigationManager.shouldNavigateToInGameView = true
                }
            } catch {
                print("error: \(error)")
            }
        }
    }
}
