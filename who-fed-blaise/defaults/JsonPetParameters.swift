//
//  PetParameters.swift
//  who-fed-blaise
//
//  Created by gude on 30.11.25.
//
import Foundation
import SwiftUI

struct WhoFedBlaiseParameters: Encodable, Decodable {

    var id: UUID
    var logLevel: String
    var hostname: String
    var port: String
    var account: String
    var feeder: String
    var name: String
    var recordNumber: Float
    var feedingNext: Float
    var notifyBefore: Float
    var notifyEvery: Float
    var wallpaperMagnifyBy: Double
    var wallpaperOffsetWidth: Double
    var wallpaperOffsetHeight: Double
    var feedingRecords: [jsonFeedingRecord] = []
    
    init(_ from: WhoFedBlaiseViewModel) throws {
        do {
            self.id = try from.getId()
            self.name = try from.getName()
            self.feeder = try from.getFeeder()
            self.account = try from.getAccount()
        } catch {
            throw error
        }
        self.hostname = from.hostname
        self.port = from.port
        self.recordNumber = from.recordNumber
        self.logLevel = from.logLevel
        self.feedingNext = from.feedingNext
        self.notifyBefore = from.notifyBefore
        self.notifyEvery = from.notifyEvery
        self.wallpaperMagnifyBy = from.wallpaperMagnifyBy
        self.wallpaperOffsetWidth = from.wallpaperOffsetWidth
        self.wallpaperOffsetHeight = from.wallpaperOffsetHeight
        self.feedingRecords = from.feedingRecords
        self.recordNumber = from.recordNumber
    }
    
    enum CodingKeys : String, CodingKey {
        case id
        case account
        case hostname
        case port
        case name = "name"
        case feeder
        case recordNumber = "recordnumber"
        case logLevel = "loglevel"
        case feedingNext = "feedingnext"
        case notifyBefore = "notificationbefore"
        case notifyEvery = "notificationevery"
        case wallpaperMagnifyBy = "wallpapermagnifyby"
        case wallpaperOffsetHeight = "wallpaperoffsetheight"
        case wallpaperOffsetWidth = "wallpaperoffsetwidth"
        case feedingRecords = "feedingrecords"
    }
}

class WhoFeFeedingRecord {
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
}
