//
//  NotificationManager.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/17.
//

import Foundation

import Combine

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    var fcmBoardStates: [String: CurrentValueSubject<BoardStateData?, Never>] = [:]

    func getOrCreateSubject(for key: String) -> CurrentValueSubject<BoardStateData?, Never> {
        if let subject = fcmBoardStates[key] {
            return subject
        } else {
            let newSubject = CurrentValueSubject<BoardStateData?, Never>(nil)
            fcmBoardStates[key] = newSubject
            return newSubject
        }
    }
}
