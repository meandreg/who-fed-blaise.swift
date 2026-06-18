//
//  PetParameters.swift
//  who-fed-blaise
//
//  Created by gude on 30.11.25.
//
import Foundation
import SwiftUI

struct JsonPetParameters: Encodable, Decodable {

    var id: UUID
    var logLevel: Int
    var hostname: String
    var port: String
    var account: String
    var feeder: String
    var role: Int
    var name: String
    var type: String
    var race: String
    var recordNumber: Float
    var feedingNext: Float
    var notifyBefore: Float
    var notifyEvery: Float
    var wallpaperMagnifyBy: Double
    var wallpaperOffsetWidth: Double
    var wallpaperOffsetHeight: Double
    
    var fontsizePetName: CGFloat
    var fontsizePetAccount: CGFloat
    var fontsizeTimestamp: CGFloat
    var fontsizeFeeder: CGFloat
    var fontsizeFooter: CGFloat
    
    var foregroundColor: Int
    var backgroundColor: Int
    
    var feedingRecords: [JsonFeedingRecord] = []
    
    init(_ from: WhoFedBlaiseViewModel) throws {
        self.id = from.id
        self.name = from.name
        self.type = from.type
        self.race = from.race
        self.feeder = from.feeder
        self.account = from.account
        self.hostname = from.hostname
        self.port = from.port
        self.role = from.role
        self.recordNumber = from.recordNumber
        self.logLevel = from.logLevel
        self.feedingNext = from.feedingNext
        self.notifyBefore = from.notifyBefore
        self.notifyEvery = from.notifyEvery
        
        self.wallpaperMagnifyBy = from.wallpaperMagnifyBy
        self.wallpaperOffsetWidth = from.wallpaperOffsetWidth
        self.wallpaperOffsetHeight = from.wallpaperOffsetHeight
        self.recordNumber = from.recordNumber
        
        self.fontsizePetName = from.fontsizePetName
        self.fontsizePetAccount = from.fontsizePetAccount
        self.fontsizeTimestamp = from.fontsizeTimestamp
        self.fontsizeFeeder = from.fontsizeFeeder
        self.fontsizeFooter = from.fontsizeFeeder
        
        self.foregroundColor = from.foregroundColor
        self.backgroundColor = from.backgroundColor
        
        for feedingRecord in from.feedingRecords {
            self.feedingRecords.append(JsonFeedingRecord(from: feedingRecord))
        }
    }
    
    enum CodingKeys : String, CodingKey {
        case id
        case account
        case hostname
        case port
        case name
        case type
        case race
        case feeder
        case role
        case recordNumber = "recordnumber"
        case logLevel = "loglevel"
        case feedingNext = "feedingnext"
        case notifyBefore = "notificationbefore"
        case notifyEvery = "notificationevery"
        case wallpaperMagnifyBy = "wallpapermagnifyby"
        case wallpaperOffsetHeight = "wallpaperoffsetheight"
        case wallpaperOffsetWidth = "wallpaperoffsetwidth"
        case feedingRecords = "feedingrecords"
        case fontsizePetName = "fontsizepetname"
        case fontsizePetAccount = "fontsizepetaccount"
        case fontsizeTimestamp = "fontsizetimestamp"
        case fontsizeFeeder = "fontsizefeeder"
        case fontsizeFooter = "fontsizefooter"
        case foregroundColor = "foregroundcolor"
        case backgroundColor = "backgroundcolor"
    }
}

class JsonFeedingRecord: Encodable, Decodable {
    var timestamp: Date
    var portion: Double
    var feeder: String
    var alias: String
    var name: String
    
    init(timestamp: Date, portion: Double, feeder: String, alias: String, name: String) {
        self.timestamp = timestamp
        self.portion = portion
        self.feeder = feeder
        self.alias = alias
        self.name = name
    }
    
    init(from: FeedingRecord) {
        self.timestamp = from.timestamp
        self.portion = from.portion
        self.feeder = from.feeder
        self.alias = from.alias
        self.name = from.name
    }
}
