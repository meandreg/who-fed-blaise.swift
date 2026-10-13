//
//  PetParameters.swift
//  who-fed-blaise
//
//  Created by gude on 01.12.25.
//

import Foundation
import UserNotifications
import Combine
import SwiftUI

class WhoFedBlaiseDefaults {
    
    static let logger = Logger(category: "WhoFedBlaiseDefauts")
    static let userDefaults: UserDefaults = .standard
    
    private static func restoreAsString(_ forKey: String) throws -> String {
        logger.setMethod("restoreAsString(\(forKey))")
        guard let string = userDefaults.string(forKey: forKey) else {
            logger.warn("UserDefault forKey \(forKey) does not exist")
            throw WhoFedBlaiseErrors.forKeyDoesNotExist(forKey)
        }
        logger.debug("UserDefauls[\(forKey)] = \(string)")
        return string
    }
        
    public static func restoreAsData(_ forKey: String) throws -> Data  {
        logger.setMethod("restoreAsData(\(forKey))")
        do {
            let string = try restoreAsString(forKey)
            guard let data = string.data(using: .utf8) else {
                throw WhoFedBlaiseErrors.failedToConvertToData(string)
            }
            return data
        } catch {
            throw error
        }
    }
    
    private static func feedingRecord(from: JsonFeedingRecord) -> FeedingRecord {
        return FeedingRecord(timestamp: from.timestamp, portion: from.portion, feeder: from.feeder, alias: from.alias, name: from.name)
    }

    public static func remove(_ key: Key) {
        remove(key.string)
        removeWallpaperImage(key)
    }

    private static func remove(_ forKey: String) {
        logger.setMethod("remove(\(forKey)")
        userDefaults.removeObject(forKey: forKey)
    }
    
    public static func save(_ data: Data, forKey: String) {
        logger.setMethod("save(data,\(forKey))")
        logger.debug("data: \(data)")
        guard let string = String(data: data, encoding: .utf8) else {
            logger.error("Failed to convert petParametersList Data to String")
            return
        }
        save(string, forKey: forKey)
    }

    private static func save(_ string: String, forKey: String) {
        logger.setMethod("save(String,\(forKey))")
        logger.debug("string: \(string)")
        userDefaults.set(string, forKey: forKey)
    }

    private static func getWallpaperPath(_ wfb: WhoFedBlaiseViewModel) throws -> URL {
        if wfb.selectedPets.isEmpty {
            throw PetArrayErrors.emptyPetList("Failed to get wallpaper path of \(wfb.account).\(wfb.name); \(wfb.selectedPets.name) is empty")
        }
        return getWallpaperPath(wfb.key)
    }

    private static func getWallpaperPath(_ key: Key) -> URL {
        return getWallpaperPath(key.string)
    }

    private static func getWallpaperPath(_ key: String) -> URL {
        logger.setMethod("getWallpaperPath(\(key))")
        let filename = key.replacingOccurrences(of: "@", with: "-at-").replacingOccurrences(of: ".", with: "-")+".jpg"
        logger.debug("Filename is \(filename)")
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(filename)
    }

    private static func getWallpaperUIImage(_ wfb: WhoFedBlaiseViewModel) throws -> UIImage {
        if wfb.selectedPets.isEmpty {
            throw PetArrayErrors.emptyPetList("Failed to get wallpaper path of \(wfb.account).\(wfb.name); \(wfb.selectedPets.name) is empty")
        }
        return try getWallpaperUIImage(wfb.key)
    }
    
    private static func getWallpaperUIImage(_ key: Key) throws -> UIImage {
        return try getWallpaperUIImage(key.string)
    }
    
    private static func getWallpaperUIImage(_ key: String) throws -> UIImage {
        logger.setMethod("getWallpaperUIImage(\(key))")
        let url = getWallpaperPath(key)
        if !FileManager.default.fileExists(atPath: url.path) {
            throw WhoFedBlaiseErrors.imageDoesNotExist(key)
        }
        do {
            let data = try Data(contentsOf: url)
            guard let uiImage = UIImage(data: data) else {
                throw WhoFedBlaiseErrors.imageDoesNotExist(key)
            }
            return uiImage
        } catch {
            logger.error("\(error)")
            throw error
        }
    }
    
    public static func getWallpaperImage(_ wfb: WhoFedBlaiseViewModel) -> Image {
        logger.setMethod("getWallpaperImage(\(wfb.short))")
        if wfb.selectedPets.isEmpty  {
            logger.warn("Failed to get wallpaper image of \(wfb.account).\(wfb.name); \(wfb.selectedPets.name) is empty")
            return Image(Defaults.WALLPAPERNAME)
        }
        return getWallpaperImage(wfb.key)
    }
    
    public static func getWallpaperImage(_ key: Key) -> Image {
        return getWallpaperImage(key.string)
    }
    
    public static func getWallpaperImage(_ key: String) -> Image {
        logger.setMethod("getWallpaperImage(\(key))")
        do {
            let uiImage = try getWallpaperUIImage(key)
            logger.info("Succesfully restored wallpaper image")
            return Image(uiImage: uiImage)
        } catch WhoFedBlaiseErrors.imageDoesNotExist(key){
            logger.info("Wallpaper image file does not exists")
            return Image(Defaults.WALLPAPERNAME)
        } catch {
            logger.error("Failed to load Wallpaper image file")
            return Image(Defaults.WALLPAPERNAME)
        }
    }
    
    public static func saveWallpaperUIImage(_ wfb: WhoFedBlaiseViewModel, uiImage: UIImage) {
        logger.setMethod("saveWallpaperImage(\(wfb.short))")
        if wfb.selectedPets.isEmpty {
            logger.warn("Failed to save wallpaper UIImage; \(wfb.selectedPets.name) is empty")
            return
        }
        saveWallpaperUIImage(wfb.key, uiImage: uiImage)
    }
    
    public static func saveWallpaperUIImage(_ key: Key, uiImage: UIImage) {
        saveWallpaperUIImage(key.string, uiImage: uiImage)
    }
    
    private static func saveWallpaperUIImage(_ key: String, uiImage: UIImage) {
        logger.setMethod("saveWallpaperUIImage(\(key),UIImage)")
        do {
            try uiImage.jpegData(compressionQuality: 0.8)?.write(to: getWallpaperPath(key))
            logger.info("Saved UIImage to \(key))")
        } catch {
            logger.error("\(error)")
        }
    }
    
    private static func removeWallpaperImage(_ wfb: WhoFedBlaiseViewModel) {
        logger.setMethod("removeWallpaperImage(\(wfb.short))")
        if wfb.selectedPets.isEmpty {
            logger.warn("Failed to remove wallpaper Image; \(wfb.selectedPets.name) is empty")
            return
        }
        removeWallpaperImage(wfb.key)
        wfb.wallpaperImage = Image(Defaults.WALLPAPERNAME)
        wfb.wallpaperMagnifyBy = Defaults.WALLPAPERMAGNIFYBY
        wfb.wallpaperOffsetWidth = Defaults.WALLPAPEROFFSETWIDTH
        wfb.wallpaperOffsetHeight = Defaults.WALLPAPEROFFSETHEIGHT
        logger.info("Removed wallpaper image")
    }
    
    private static func removeWallpaperImage(_ key: Key) {
        removeWallpaperImage(key.string)
    }
    
    private static func removeWallpaperImage(_ key: String) {
        logger.setMethod("removeWallpaperImage(\(key))")
        do {
            try FileManager.default.removeItem(at: WhoFedBlaiseDefaults.getWallpaperPath(key))
            logger.info("Removed UIImage")
        } catch {
            logger.error("\(error)")
        }
    }
    
    static func restoreDeviceToken() -> String {
        return userDefaults.string(forKey: Labels.DEVICETOKEN) ?? Defaults.DEVICETOKEN
    }
    
    static func saveDeviceToken() {
        userDefaults.set(WhoFedBlaiseViewModel.deviceToken, forKey: Labels.DEVICETOKEN)
    }
    
    
}
