//
//  AppView.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/08.
//
import SwiftUI

struct AppView: View {
    @EnvironmentObject var navigationState: NavigationStateManager

    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "apple.logo")
                    .imageScale(.large)
                    .foregroundColor(.gray)
                Text("Fog of war chess")
                    .padding(4)
                Spacer()
                    .frame(height: 70)
                NavigationLink(
                    destination: InGameView(
                        color: .white,
                        shouldReset: true,
                        serverType: .singlePlay
                    )
                ) {
                    Text("SinglePlayer")
                        .frame(width: 100)
                        .padding(6)
                        .overlay(RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.accentColor, lineWidth: 4))
                }
                NavigationLink(destination: TurnCoverView(
                    color: .white,
                    shouldReset: true
                )) {
                    Text("Pass And Play")
                        .frame(width: 100)
                        .padding(6)
                        .overlay(RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.accentColor, lineWidth: 4))
                }
                NavigationLink(destination: WaitingRoomView()) {
                    Text("Create a room")
                        .frame(width: 100)
                        .padding(6)
                        .overlay(RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.accentColor, lineWidth: 4))
                }
                NavigationLink(destination: EnterRoomView()) {
                    Text("Enter a room")
                        .frame(width: 100)
                        .padding(6)
                        .overlay(RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.accentColor, lineWidth: 4))
                }
                NavigationLink(destination: InGameView(
                    color: .white,
                    shouldReset: false,
                    serverType: .remote
                ), isActive: $navigationState.shouldNavigateToInGameView) {
                    EmptyView()
                }
            }
        }
            .ignoresSafeArea()
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
