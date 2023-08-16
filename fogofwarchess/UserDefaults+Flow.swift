//
//  UserDefaults+Flow.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/16.
//

import Foundation
import Combine

extension UserDefaults {
    static let fcmTokenKey = "FCM_TOKEN"

    var fcmTokenPublisher: AnyPublisher<String?, Never> {
        return self.publisher(for: \.fcmToken)
            .eraseToAnyPublisher()
    }

    @objc dynamic var fcmToken: String? {
        get {
            return string(forKey: UserDefaults.fcmTokenKey)
        }
        set {
            set(newValue, forKey: UserDefaults.fcmTokenKey)
        }
    }
}
