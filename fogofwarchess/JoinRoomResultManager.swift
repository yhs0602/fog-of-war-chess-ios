//
//  JoinRoomResultManager.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/18.
//

import Foundation
import Combine

class JoinRoomResultManager {
    private init() { }
    static let shared = JoinRoomResultManager()
    let joinRoomResultBoardState = CurrentValueSubject<BoardStateData?, Never>(nil)
}
