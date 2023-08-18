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

    let payloadSubject = CurrentValueSubject<String?, Never>(nil)
}
