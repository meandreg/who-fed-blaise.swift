//
//  HttpFeedingRecords.swift
//  who-fed-blaise
//
//  Created by gude on 15.12.25.
//

import Foundation

struct HttpFeedingRecords : Encodable, Decodable {
    var pet: UUID
    var feedingRecords: [HttpFeedingRecords]
}

struct HttpFeedingRecord : Encodable, Decodable{
    var timestamp: Date
    var feeder: String
    var alias: String
    var portion: Float
}

