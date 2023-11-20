//
//  Model.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 26.03.23.
//

import Foundation

struct FeedingModel {
    
    var petName: String

    init() {
        petName = "blaise"
        feedingRecords = []
    }

    var feedingRecords: Array<FeedingRecord>
}

struct FeedingRecord {
    var timestamp: Date
    var feeder: String
    var portion: Int
}

struct FeedingURLSession {
    var url: String
    var recordNumber: Int
    var returnCode: Int?
    var errorMessage: String?
    
    init() {
        //url = "https://who-fed-blaise.o27h4hea3ks.eu-de.codeengine.appdomain.cloud/"
        url = "http://localhost:8080/"
        recordNumber = 3
    }
}

