//
//  File.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 16.09.24.
//

import Foundation

struct ApplePushNotificationModel {
    
    static var deviceTokenSubscribed : Bool = false
    static var deviceTokenString : String = ""

    static func isSubscribed() -> Bool {
        return deviceTokenSubscribed
    }
    
    static func subscribe()  {
        deviceTokenSubscribed = true
    }

    static func unsubscribe()  {
        deviceTokenSubscribed = false
    }

    static func isDeviceTokenSet() -> Bool {
        return !deviceTokenString.isEmpty
    }
}
