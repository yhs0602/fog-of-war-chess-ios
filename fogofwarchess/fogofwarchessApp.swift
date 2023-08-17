//
//  fogofwarchessApp.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/08.
//

import SwiftUI

@main
struct fogofwarchessApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var navigationState = NavigationStateManager.shared

    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(navigationState)
        }
    }
}
