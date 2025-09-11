//
//  Parameters.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 07.10.24.
//

import Foundation
import os
import SwiftUI

struct Parameters {
    
    static let logger = Logger(Logger.PARAMETER_INFO, category: "Logger")
    static let userDefaults: UserDefaults = UserDefaults()

    static func getAppName() -> String {
        return UserDefaults.standard.string(forKey: Labels.APPNAME) ?? Defaults.APPNAME
    }

    static func setAppName(_ appName: String) {
        userDefaults.set(appName, forKey: Labels.APPNAME)
    }

    static func getCustomizeWallPaper() -> Bool {
        let result = UserDefaults.standard.bool(forKey: Labels.CUSTOMIZEWALLPAPER)
        logger.info(String(format: "CUSTOMIZEWALLPAPER: %@", String(result)))
        return result
    }

    static func setCustomizeWallPaper(_ customizeWallPaper: Bool) {
        userDefaults.set(customizeWallPaper, forKey: Labels.CUSTOMIZEWALLPAPER)
    }

    static func getAccount() -> String! {
        return userDefaults.string(forKey: Labels.ACCOUNT) ?? Defaults.ACCOUNT
    }

    static func setAccount(_ account: String) {
        logger.info("SET \(Labels.ACCOUNT) = \(account)")
        userDefaults.set(account, forKey: Labels.ACCOUNT)
    }

    static func getPetName() -> String! {
        return userDefaults.string(forKey: Labels.PETNAME) ?? Defaults.PETNAME
    }

    static func setPetName(_ petName: String) {
        logger.info("SET \(Labels.PETNAME) = \(petName)")
        userDefaults.set(petName, forKey: Labels.PETNAME)
    }

    static func getURL() -> String {
        return userDefaults.string(forKey: Labels.URL) ?? Defaults.URL
    }
    
    static func setURL(_ url: String) {
        userDefaults.set(url, forKey: Labels.URL)
    }

    static func getRecordNumber() -> Float {
        var value:Int = userDefaults.integer(forKey: Labels.RECORDNUMBER)
        if value==0 {value = Defaults.RECORDNUMBER}
        return Float(value)
    }
    
    static func setRecordNumber(_ recordNumber: Int) {
        userDefaults.set(recordNumber, forKey: Labels.RECORDNUMBER)
    }

    static func getFeeder() -> String! {
        return userDefaults.string(forKey: Labels.FEEDER) ?? Parameters.getAccount()
    }
    
    static func setFeeder(_ feeder: String) {
        userDefaults.set(feeder, forKey: Labels.FEEDER)
    }

    static func getPassword() -> String {
        return userDefaults.string(forKey: Labels.PASSWORD) ?? Defaults.PASSWORD
    }
    
    static func setPassword(_ password: String) {
        userDefaults.set(password, forKey: Labels.PASSWORD)
    }

    static func getLogLevel() -> String {
        return userDefaults.string(forKey: Labels.LOGLEVEL) ?? Defaults.LOGLEVEL
    }
    
    static func setLogLevel(_ logLevel: String) {
        userDefaults.set(logLevel, forKey: Labels.LOGLEVEL)
    }

    static func getDeviceToken() -> String {
        return userDefaults.string(forKey: Labels.DEVICETOKEN) ?? Defaults.DEVICETOKEN
    }
    
    static func setDeviceToken(_ deviceToken: String) {
        logger.info("SET \(Labels.DEVICETOKEN) = \(deviceToken)")
        userDefaults.set(deviceToken, forKey: Labels.DEVICETOKEN)
    }

    static func getFeedingNext() -> Int {
        var value:Int = userDefaults.integer(forKey: Labels.FEEDINGNEXT)
        if value == 0 {value = Defaults.FEEDINGNEXT}
        return value
    }
    
    static func setFeedingNext(_ feedingNext: Int) {
        userDefaults.set(feedingNext, forKey: Labels.FEEDINGNEXT)
    }

    static func getNotificationBefore() -> Int {
        var value:Int = userDefaults.integer(forKey: Labels.NOTIFYBEFORE)
        if value == 0 {value = Defaults.NOTIFYBEFORE}
        return value
    }
    
    static func setNotificationBefore(_ notificationBefore: Int) {
        userDefaults.set(notificationBefore, forKey: Labels.NOTIFYBEFORE)
    }

    static func getNotifyEvery() -> Int {
        var value:Int = userDefaults.integer(forKey: Labels.NOTIFEVERY)
        if value==0 {value = Defaults.NOTIFYEVERY}
        return value
    }
    
    static func setNotifyEvery(_ notifyEvery: Int) {
        userDefaults.set(notifyEvery, forKey: Labels.NOTIFEVERY)
    }

    static func getWallPaperPath() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(Parameters.getPetName() + ".jpg")
    }

    static func getWallPaperUIImage() -> UIImage? {
        let fileURL = getWallPaperPath()
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }
    
    static func getWallPaperImage() -> Image {
        let uiImageData = getWallPaperUIImage()
        if uiImageData != nil {
            return Image(uiImage: uiImageData!)
        }
        return Image(Defaults.WALLPAPERNAME)
    }
 }

struct Labels {
    static let WALLPAPERNAME="wallpapername"
    static let CUSTOMIZEWALLPAPER="customizewallpaper"
    static let ACTION="action"
    static let APPNAME="appname"
    static let URL="url"
    static let ACCOUNT="account"
    static let PETNAME="petname"
    static let PREVIOUS="previous"
    static let FEEDER="feeder"
    static let ALIAS="alias"
    static let PASSWORD="password"
    static let PORTION="portion"
    static let TIMESTAMP="timestamp"
    static let RECORDNUMBER="recordnumber"
    static let DEVICETOKEN="devicetoken"
    static let LOGLEVEL="loglevel"
    
    static let FEEDINGNEXT="feedingnext"
    static let NOTIFYBEFORE="notifbefore"
    static let NOTIFEVERY="notifevery"
    
    static let APPFEEDING:String="feeding"
    static let APPNOTIFICATION:String="notification"
    
    static let ACTION_GET:String="get"
    static let ACTION_ADD:String="add"
    static let ACTION_DEL:String="del"
    static let ACTION_SUB:String="sub"
    static let ACTION_UNS:String="uns"

    static let RETURNCODE="returncode"
    static let MESSAGE="message"
}

struct Defaults {
    static let APPNAME:String="who-fed-blaise"
    static let CUSTOMIZEWALLPAPER:Bool=true
    static let WALLPAPERNAME:String="Blaise"
    static let URL:String="http://hostname:port"
    static let ACCOUNT:String="alias@email.com"
    static let RECORDNUMBER:Int=3
    static let DEVICETOKEN:String=""
    static let LOGLEVEL:String=Logger.PARAMETER_DEFAULT

    static let PETNAME:String="petname"
    static let FEEDER:String=Defaults.ACCOUNT
    static let PASSWORD:String=""
    static let PORTION:Int=1
    static let FEEDINGNEXT:Int=60*12
    static let NOTIFYBEFORE:Int=60
    static let NOTIFYEVERY:Int=10
}
