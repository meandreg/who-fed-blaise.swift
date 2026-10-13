//
//  HttpRequestBody.swift
//  who-fed-blaise
//
//  Created by gude on 01.12.25.
//

import Foundation

class HttpRequestBody: Encodable, Decodable {
    var version: Int = 2
    var isSimulator: Bool = WhoFedBlaiseViewModel.isSimulator()
    var hostname: String
    var port: Int
    var action: String
    var logLevel: String
    var feeder: String
    //var alias: String?
    var password: String
    //var role: Int?
    //var account: String?
    var pet: UUID?
    var recordNumber: Int?
    var deviceToken: String?
    var timestamp: Date?
    var portion: Float?

    // Base v2 request
    init(action: String, logLevel: String, hostname: String, port: Int, feeder: String, password: String) {
        self.action=action
        self.logLevel=logLevel
        self.hostname=hostname
        self.port=port
        self.feeder=feeder
        self.password=password
    }

    // Request v2 feeder's pet list
    static func HttpRequestFeederPets(_ wfb: WhoFedBlaiseViewModel) -> HttpRequestBody {
        return HttpRequestBody(action: Labels.ACTION_GETFEEDERPETS, logLevel: wfb.logLevel, hostname: wfb.hostname, port: wfb.intPort, feeder: wfb.feeder, password: wfb.password)
    }
    
    // Request pet's feeding records
    convenience init(action: String, pet: Pet) {
        let feeder = pet.feeder
        let account = pet.account
        self.init(action: action, logLevel: pet.logLevel, hostname: account.hostname, port: account.port, feeder: feeder.email, password: feeder.password)
        self.pet = pet.id
        self.deviceToken = WhoFedBlaiseViewModel.deviceToken
    }
    
    // Request pet's feeding records
    convenience init(action: String, wfb: WhoFedBlaiseViewModel) {
        self.init(action: action, logLevel: wfb.logLevel, hostname: wfb.hostname, port: Int(wfb.port) ?? 80, feeder: wfb.feeder, password: wfb.password)
        self.pet = wfb.id
        self.recordNumber = Int(wfb.recordNumber)
        self.deviceToken = WhoFedBlaiseViewModel.deviceToken
    }
    
    static func HttpRequestFeedingRecords(_ wfb: WhoFedBlaiseViewModel) -> HttpRequestBody {
        return HttpRequestBody(action: Labels.ACTION_GETFEEDINGRECORDS, wfb: wfb)
    }
    
    static func HttpRequestLastUpdated(_ pet: Pet) -> HttpRequestBody {
        let request = HttpRequestBody(action: Labels.ACTION_GETLASTUPDATED, pet: pet)
        request.recordNumber = 1
        return request
    }
    
    static func HttpRequestDelFeedingRecord(_ wfb: WhoFedBlaiseViewModel, timestamp: Date) -> HttpRequestBody {
        let request = HttpRequestBody(action: Labels.ACTION_DELFEEDINGRECORD, wfb: wfb)
        request.timestamp = timestamp
        return request
    }
    
    static func HttpRequestAddFeedingRecord(_ wfb: WhoFedBlaiseViewModel, timestamp: Date, portion: Float) -> HttpRequestBody {
        let request = HttpRequestBody(action: Labels.ACTION_ADDFEEDINGRECORD, wfb: wfb)
        request.portion = portion
        request.timestamp = timestamp
        return request
    }
    
    enum CodingKeys : String, CodingKey {
        case version
        case isSimulator = "issimulator"
        case action
        case logLevel = "loglevel"
        case hostname
        case port
        case feeder
        //case alias
        case password
        //case role
        //case account = "account"
        case pet
        case recordNumber = "recordnumber"
        case deviceToken = "devicetoken"
        case timestamp
        case portion = "portion"
    }
}
