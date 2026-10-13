//
//  FeedingRecord.swift
//  who-fed-blaise
//
//  Created by gude on 04.03.26.
//

import Foundation

class FeedingRecord: Decodable, Encodable {
    var timestamp: Date
    var portion: Double
    var feeder: String
    var alias: String
    var name: String
    var canBeDeleted: Bool
    
    init(timestamp: Date, portion: Double, feeder: String, alias: String, name: String, canBeDeleted: Bool = false) {
        self.timestamp = timestamp
        self.portion = portion
        self.feeder = feeder
        self.alias = alias
        self.name = name
        self.canBeDeleted = canBeDeleted
    }
    
    convenience init(timestamp: Date, portion: Double, feeder: Feeder) {
        self.init(timestamp: timestamp, portion: portion, feeder: feeder.email, alias: feeder.alias, name: feeder.name, canBeDeleted: true)
    }
    
    var string: String  {
        return Json.stringify(encodable: self)
    }
}
