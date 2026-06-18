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
    
    static var shared: AppDelegate!
    
    let logger = Logger(category: "AppDelegate")

    var whoFedBlaiseViewModel: WhoFedBlaiseViewModel!
    
    func application(_ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        logger.setMethod("application(...didFinishLaunchingWithOptions...)")
        AppDelegate.shared = self
        UIApplication.shared.registerForRemoteNotifications()
        logger.debug("Call UIApplication.shared.registerForRemoteNotifications()")
        UNUserNotificationCenter.current().delegate = self
        logger.debug("UNUserNotificationCenter.current().delegate = self")
        return true
    }
    
    func application(_ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error) {
        logger.setMethod("application(...didFailToRegisterForRemoteNotificationsWithError...)")
        logger.error("\(error)")
    }
    
    func application(_ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        logger.setMethod("application(...didRegisterForRemoteNotificationsWithDeviceToken...)")
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        WhoFedBlaiseViewModel.deviceToken = token
        logger.info("Device token = \(WhoFedBlaiseViewModel.deviceToken)")
        WhoFedBlaiseDefaults.saveDeviceToken()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        logger.setMethod("application(...didReceiveRemoteNotification...)")
        if let aps = userInfo["aps"] as? [String: AnyObject] {
            logger.debug("Notification received: \(aps)")
        }
        if let uuidString = userInfo["id"] as? String {
            logger.debug("Pet id received: \(uuidString)")
            let id = UUID(uuidString: uuidString)!
            self.whoFedBlaiseViewModel.switchTo(id)
        }
        logger.debug("End")
        completionHandler(.newData)
    }
}
