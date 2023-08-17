//
//  NavgiationStateManager.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/17.
//

import Foundation
import Combine

enum NavigationState {
    case main
    case ingame
    case joinRoom
    case createRoom
    case turnCover
}

class NavigationStateManager: ObservableObject {
    @Published var currentView: NavigationState = .main
}
