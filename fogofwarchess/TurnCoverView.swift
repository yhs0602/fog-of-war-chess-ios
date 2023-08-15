//
//  TurnCoverView.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/15.
//

import SwiftUI

struct TurnCoverView: View {
    @State private var isNavigating = false

    let color: String
    let shouldReset: Bool

    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            Text("color: \(color)")
                .foregroundColor(color == "BLACK" ? .white : .black)
//            Text("shouldReset: \(shouldReset)")
//                .foregroundColor(color == "BLACK" ? .white : .black)
            NavigationLink(destination: InGameView()) {
                Text("Start")
            }
            Spacer()
        }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(color == "BLACK" ? Color.black : Color.white)
            .navigationBarBackButtonHidden(true) // Hide back button for view2
    }
}

struct TurnCoverView_Previews: PreviewProvider {
    static var previews: some View {
        TurnCoverView(
            color: "BLACK", shouldReset: true
        )
    }
}
