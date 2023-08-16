//
//  FetchFCMToken.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/16.
//

import Foundation
import Firebase

func fetchFCMToken() async throws -> String {
    return try await withCheckedThrowingContinuation { continuation in
        Messaging.messaging().token { token, error in
            if let error = error {
                continuation.resume(throwing: error)
            } else {
                continuation.resume(returning: token ?? "")
            }
        }
    }
}
