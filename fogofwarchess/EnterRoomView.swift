//
//  EnterRoomView.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/10.
//

import SwiftUI

struct EnterRoomView: View {
    @State private var roomId: String = ""
    @State private var navigateToRoom = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Room ID:")
            TextField("Enter your room ID", text: $roomId)
                .padding()
                .border(Color.gray, width: 1)
            Button("Enter!") {
                navigateToRoom = true
            }
            Spacer()
        }.padding()
            .navigationDestination(isPresented: $navigateToRoom) {
                RoomView(roomId: roomId)
            }
    }
}

struct EnterRoomView_Previews: PreviewProvider {
    static var previews: some View {
        EnterRoomView()
    }
}
