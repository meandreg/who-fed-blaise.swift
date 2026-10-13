//
//  PetPickerItem.swift
//  who-fed-blaise
//
//  Created by gude on 02.01.26.
//

import Foundation

class Pet: Identifiable, Decodable, Encodable {
    var id: UUID
    var name: String
    //var alias: String
    var type: String
    var race: String
    var logLevel: String
    var account: Account
    var feeder: Feeder
    var canFeed: Bool
    var recordNumber: Int
    var feedingRecords: [FeedingRecord] = []
    
    var key: Key {
        return Key(account.hostname, account.port, id, feeder.email)
    }
    
    var shortId: String {
        return Pet.shortId(id)
    }
    
    static func shortId(_ id: UUID) -> String {
        return id.uuidString.split(separator: "-").first.map(String.init) ?? ""
    }
    
    var short: String {
        return "\(account.alias).\(name)(\(shortId))"
    }
    
    static func short(_ account: String, _ name: String, _ id: UUID) -> String {
        return "\(account).\(name)(\(Pet.shortId(id)))"
    }
    
    var long: String {
        return Pet.long(account.hostname, account.port, feeder.email, account.name, name, id)
    }

    static func long(_ hostname: String, _ port: Int, _ feeder: String, _ account: String, _ pet: String, _ id: UUID) -> String {
        return "\(hostname):\(port)@\(feeder)://\(account).\(pet)(\(id))"
    }

    init(id: UUID, name: String, type: String, race: String, logLevel: String, account: Account, feeder: Feeder, canFeed: Bool, recordNumber: Int, feedingRecords: [FeedingRecord] = []) {
        self.id = id
        self.canFeed = canFeed
        self.recordNumber = recordNumber
        self.name = name
        self.type = type
        self.race = race
        self.logLevel = logLevel
        self.feeder = feeder
        self.account = account
        self.feedingRecords = feedingRecords
    }
    
    func lastRecord() throws -> FeedingRecord {
        guard let feedingRecord = feedingRecords.first else {
            throw PetErrors.noFeedingRecord(self)
        }
        return feedingRecord
    }
    
    func lastUpdated() throws -> Date {
        return try lastRecord().timestamp
    }
    
    var string: String {
        return Json.stringify(encodable: self)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.race, forKey: .race)
        try container.encode(self.canFeed, forKey: .canFeed)
        try container.encode(self.recordNumber, forKey: .recordNumber)
        try container.encode(self.logLevel, forKey: .logLevel)
        try container.encode(self.feeder, forKey: .feeder)
        try container.encode(self.account, forKey: .account)
        try container.encode(self.feedingRecords, forKey: .feedingRecords)
    }
}


