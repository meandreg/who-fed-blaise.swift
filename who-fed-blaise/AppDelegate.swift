//
//  AppDelegate.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 07.06.24.
//

import Foundation
import UIKit
//import os

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    let logger = Logger(Logger.PARAMETER_DEBUG, category: "AppDelegate")
    
    //static var deviceToken: String = ""

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        logger.debug("func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool")
        UIApplication.shared.registerForRemoteNotifications()
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        logger.debug("func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)")
        logger.error("Remote notification is unavailable: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        logger.debug("func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)")
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        forwardTokenToServer(token: token)
    }
    
    func forwardTokenToServer(token: String) {
        logger.debug("func forwardTokenToServer(token: Data)")
        logger.debug("token = \(token)")
        Parameters.setDeviceToken(token)
        //logger.info("deviceToken = \(AppDelegate.deviceToken)")
        //ApplePushNotificationModel.deviceTokenString = tokenComponents.joined()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}

