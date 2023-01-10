//
//  Model.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 08.06.22.
//

import Foundation

struct FeedingRecord {
    let timestamp: Date
    let feeder: String
    let portion: Int
}

struct FeedingData {
    
    let petName: String
    let feedingRecords: [FeedingRecord]
    
    init(petName: String, feedingRecords: [FeedingRecord]) {
        self.petName = petName
        self.feedingRecords = feedingRecords
    }
    
}
