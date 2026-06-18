//
//  HttpRequestBody.swift
//  who-fed-blaise
//
//  Created by gude on 01.12.25.
//

import Foundation

class HttpRequestBody: Encodable, Decodable {
    var version: Int = 2
    var isProduction: Bool = isSimulator()
    var action: String
    var logLevel: Int?
    var feeder: String?
    var role: Int?
    var account: String?
    var pet: UUID?
    var recordNumber: Int?
    var deviceToken: String?
    var timestamp: Date?
    var portion: Float?

    // Base v2 request
    init(action: String, logLevel: Int?=nil, feeder: String?=nil) {
        self.action=action
        self.logLevel=logLevel
        self.feeder=feeder
    }

    // Request v2 feeder's pet list
    static func HttpRequestFeederPets(_ wfb: WhoFedBlaiseViewModel) throws -> HttpRequestBody {
        return HttpRequestBody(action: Labels.ACTION_GETFEEDERPETS, logLevel: wfb.logLevel, feeder: wfb.feeder)
    }
    
    // Request v2 device latest updated pet id
    static func HttpRequestUpdatedPet() throws -> HttpRequestBody {
        let request = HttpRequestBody(action: Labels.ACTION_GETUPDATEDPET)
        request.deviceToken=WhoFedBlaiseViewModel.deviceToken
        return request
    }
    
    // Request pet's feeding records
    convenience init(action: String, logLevel: Int, feeder: String, pet: UUID, recordNumber: Int) {
        self.init(action: action, logLevel: logLevel, feeder: feeder)
        self.pet = pet
        self.recordNumber = recordNumber
        self.deviceToken = WhoFedBlaiseViewModel.deviceToken
    }
    
    static func HttpRequestFeedingRecords(_ wfb: WhoFedBlaiseViewModel) throws -> HttpRequestBody {
        return HttpRequestBody(action: Labels.ACTION_GETFEEDINGRECORDS, logLevel: wfb.logLevel, feeder: wfb.feeder,  pet: wfb.id, recordNumber: Int(wfb.recordNumber))
    }
    
    // Request to delete feeding record
    convenience init(action: String, logLevel: Int,feeder: String, pet: UUID, recordNumber: Int, timestamp: Date) {
        self.init(action: action, logLevel: logLevel, feeder: feeder, pet: pet, recordNumber: recordNumber)
        self.timestamp = timestamp
    }
    
    static func HttpRequestDelFeedingRecord(_ wfb: WhoFedBlaiseViewModel, timestamp: Date) throws -> HttpRequestBody {
        return HttpRequestBody(action: Labels.ACTION_DELFEEDINGRECORD, logLevel: wfb.logLevel, feeder: wfb.feeder, pet: wfb.id, recordNumber: Int(wfb.recordNumber), timestamp: timestamp)
    }
    
    // Request to add feeding record
    convenience init(action: String, logLevel: Int,feeder: String, pet: UUID, recordNumber: Int, timestamp: Date, portion: Float) {
        self.init(action: action, logLevel: logLevel, feeder: feeder, pet: pet, recordNumber: recordNumber, timestamp: timestamp)
        self.portion = portion
    }
    
    static func HttpRequestAddFeedingRecord(_ wfb: WhoFedBlaiseViewModel, timestamp: Date, portion: Float) throws -> HttpRequestBody {
        return HttpRequestBody(action: Labels.ACTION_ADDFEEDINGRECORD, logLevel: wfb.logLevel, feeder: wfb.feeder, pet: wfb.id, recordNumber: Int(wfb.recordNumber), timestamp: timestamp, portion: portion)
    }
    
    enum CodingKeys : String, CodingKey {
        case version
        case isProduction = "isproduction"
        case action
        case logLevel = "loglevel"
        case feeder
        case role
        case account = "account"
        case pet
        case recordNumber = "recordnumber"
        case deviceToken = "devicetoken"
        case timestamp
        case portion = "portion"
    }
}
