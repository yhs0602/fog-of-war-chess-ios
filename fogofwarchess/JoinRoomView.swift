//
//  EnterRoomView.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/10.
//

import SwiftUI

struct EnterRoomView: View {
    @ObservedObject var viewModel = JoinRoomViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Room ID:")
            TextField("Enter your room ID", text: $viewModel.roomId)
                .padding()
                .border(Color.gray, width: 1)
            Button("Enter!") {
                viewModel.joinRoom()
//                navigateToRoom = true
            }.disabled(!viewModel.canJoinRoom)
            Spacer()
        }.padding()
//            .navigationDestination(isPresented: $navigateToRoom) {
//                InGameView(color: .white, shouldReset: true, serverType: .remote)
//            }
    }
}

struct EnterRoomView_Previews: PreviewProvider {
    static var previews: some View {
        EnterRoomView()
    }
}
