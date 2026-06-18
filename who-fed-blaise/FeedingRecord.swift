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
    
    init(timestamp: Date, portion: Double, feeder: String, alias: String, name: String) {
        self.timestamp = timestamp
        self.portion = portion
        self.feeder = feeder
        self.alias = alias
        self.name = name
    }
}
