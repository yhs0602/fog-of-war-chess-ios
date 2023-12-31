//
//  AppDelegate+UNUserNotificationCenterDelegate.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/16.
//

import Foundation
import UserNotifications
import Gzip

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Change this to your preferred presentation option
        let navigationState = NavigationStateManager.shared
        print("userNotificationCenterWillPresentWithCompletionHandler \(navigationState.currentView)")
        if navigationState.currentView == .ingame {
            // handle data message
            let userInfo = notification.request.content.userInfo as! [String: AnyObject]
            print("Background ")
            print(userInfo)
            if let payload = userInfo["payload"] as? String {
                let decodedPayload = decodeFCMPayload(encodedPayload: payload) // try? decodePayload(payload: payload)
                if let decodedPayload {
                    NotificationManager.shared.getOrCreateSubject(for: decodedPayload.roomId).send(decodedPayload)
                } else {
                    print("Fatal error: the notification payload is not json")
                }
            } else {
                print("the payload was not string")
            }
            completionHandler([])
        } else {
            completionHandler([[.banner, .sound, .list]]) // banner: even when app is on, .list: list
        }
    }

    // When the user clicks the notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo as! [String: AnyObject]
        print("userNotificationCenterDidReceiveWithCompletionHandler")
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        print("Noti tapped ")
        print(userInfo)
        if let payload = userInfo["payload"] as? String {
            let decodedPayload = decodeFCMPayload(encodedPayload: payload) // try? decodePayload(payload: payload)
            if let decodedPayload {
                NotificationManager.shared.getOrCreateSubject(for: decodedPayload.roomId).send(decodedPayload)
                let navigationController = NavigationStateManager.shared // Assume a singleton instance or get it from the environment
                navigationController.roomId = decodedPayload.roomId
                navigationController.shouldNavigateToInGameView = true
            } else {
                print("Fatal error: the notification payload is not json")
            }
        } else {
            print("the payload was not string")
        }
        completionHandler()
    }

    func decodePayload(payload: String) throws -> BoardStateData {
        guard let data = payload.data(using: .utf8) else {
            throw NSError(domain: "Invalid payload", code: 0, userInfo: nil)
        }
        let decoder = JSONDecoder()
        return try decoder.decode(BoardStateData.self, from: data)
    }
}

func decodeFCMPayload(encodedPayload: String) -> BoardStateData? {
    print("payload: \(encodedPayload)")

    // 1. Decode Base64
    guard let compressedData = Data(base64Encoded: encodedPayload) else {
        print("Error: Failed to decode base64.")
        return nil
    }

    // 2. Decompress GZIP
    var decompressedData: Data
    do {
        if compressedData.isGzipped {
            decompressedData = try compressedData.gunzipped()
        } else {
            decompressedData = compressedData
        }
    } catch {
        print("Error: Failed to decompress data.")
        return nil
    }

    // 3. Decode Json
    let decoder = JSONDecoder()
    do {
        let boardState = try decoder.decode(BoardStateData.self, from: decompressedData)
        return boardState
    } catch {
        print("Error decoding JSON: \(error)")
        return nil
    }
}
