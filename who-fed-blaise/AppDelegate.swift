//
//  AppDelegate.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 07.06.24.
//

import Foundation
import UIKit
import os

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    let logger = Logger(subsystem: "who-fed-blaise", category: "AppDelegate")
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.registerForRemoteNotifications()
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        logger.error("Remote notification is unavailable: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        forwardTokenToServer(token: <#T##Data#>)
    }
    
    func forwardTokenToServer(token: Data) {
        let tokenComponents = token.map { data in String(format: "%02.2hhx", data)}
        let deviceTokenString = tokenComponents.joined()
    }
}

