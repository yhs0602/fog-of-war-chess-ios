//
//  TurnCoverView.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/15.
//

import SwiftUI

struct TurnCoverView: View {
    @State private var isNavigating = false
    @EnvironmentObject var navigationState: NavigationStateManager

    let color: ChessColor
    let shouldReset: Bool

    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            Text("color: \(color.rawValue)")
                .foregroundColor(color == .black ? .white : .black)
            Text("shouldReset: \(shouldReset.description)")
                .foregroundColor(color == .black ? .white : .black)
            NavigationLink(
                destination: InGameView(
                    color: color,
                    shouldReset: shouldReset,
                    serverType: .passNPlay
                )
            ) {
                Text("Start")
            }
            Spacer()
        }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(color == .black ? Color.black : Color.white)
            .navigationBarBackButtonHidden(true) // Hide back button for view2
            .onAppear {
                self.navigationState.currentView = .turnCover
            }
    }
}

struct TurnCoverView_Previews: PreviewProvider {
    static var previews: some View {
        TurnCoverView(
            color: .black, shouldReset: true
        )
    }
}
