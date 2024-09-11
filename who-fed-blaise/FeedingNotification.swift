//
//  File.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 06.01.24.
//

import SwiftUI
import UserNotifications
import os

class NotificationManager {
    
    let logger = Logger(subsystem: "who-fed-blaise", category: "FeedingNotification")
    
    static let notificatioManager = NotificationManager()
    
    func requestNotification() {
        let notificationOptions: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: notificationOptions) {(success, error) in
            if let error = error {
                self.logger.info("Request notifocation authorization error: \(error)")
            } else {
                self.logger.info("Request notifocation authorization success")
            }
        }
    }
    
    

}

