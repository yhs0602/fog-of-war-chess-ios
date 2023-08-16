//
//  WaitingRoomView.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/10.
//

import SwiftUI

struct WaitingRoomView: View {
    @ObservedObject var viewModel = CreateRoomViewModel()
    @State private var isShareSheetPresented: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Toggle(isOn: $viewModel.isWhite) {
                    Text("Is White")
                }

                Button("Create Room") {
                    viewModel.createRoom()
                }
                    .disabled(!viewModel.canCreateRoom)

                HStack(spacing: 16) {
                    Text("Room Number: \(viewModel.roomId)")
                        .frame(maxWidth: .infinity)

                    Button("Copy") {
                        UIPasteboard.general.string = viewModel.roomId
                    }

                    Button("Share") {
                        isShareSheetPresented.toggle()
                    }.sheet(isPresented: $isShareSheetPresented) {
                        ActivityViewController(activityItems: [viewModel.roomId])
                    }
                }
            }
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        }
            .onAppear {
            viewModel.prepareCreateRoom()
        }
    }
}

struct WaitingRoomView_Previews: PreviewProvider {
    static var previews: some View {
        WaitingRoomView()
    }
}
