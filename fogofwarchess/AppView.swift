//
//  AppView.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/08.
//
import SwiftUI

struct AppView: View {
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
                NavigationLink(destination: ContentView()) {
                    Text("Start!")
                        .frame(width: 100)
                        .padding(6)
                        .overlay(RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.accentColor, lineWidth: 4))
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
