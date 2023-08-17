//
//  AppDelegate+UNUserNotificationCenterDelegate.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/16.
//

import Foundation
import UserNotifications
extension AppDelegate: UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Change this to your preferred presentation option
        let navigationState = NavigationStateManager.shared
        if navigationState.currentView == .ingame {
            // handle data message
            let userInfo = notification.request.content.userInfo as! [String: AnyObject]
            print("Background ")
            print(userInfo)
            if let payload = userInfo["payload"] as? String {
                NotificationManager.shared.payloadSubject.send(payload)
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
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        print("Noti tapped ")
        print(userInfo)
        if let payload = userInfo["payload"] as? String {
            NotificationManager.shared.payloadSubject.send(payload)
        } else {
            print("the payload was not string")
        }
        let navigationController = NavigationStateManager.shared // Assume a singleton instance or get it from the environment
        navigationController.shouldNavigateToInGameView = true

        completionHandler()
    }
}
