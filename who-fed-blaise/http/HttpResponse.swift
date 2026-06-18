//
//  SqlResponse.swift
//  who-fed-blaise
//
//  Created by gude on 01.12.25.
//
import Foundation

class SqlResponse: Decodable {
    var returncode: Int = 0
    var message: String!
    var data: SqlResponseData?
}

class SqlResponseData: Decodable {
    var action: String
    var feeder: String
    var account: String?
    //var feederaccounts: [String]?
    var feederpets: [SqlPet]?
    //var accountpets: [SqlPet]?
    var pet: SqlPet?
    var updatedpet: UpdatedPet?
    
    class UpdatedPet: Decodable {
        var pet: UUID
    }
}

class SqlPet: Decodable, Identifiable {
    var id: UUID
    var name: String
    var type: String
    var race: String
    var account: String
    var feeder: String
    var alias: String
    var role: Int
    var feedingRecords: [SqlFeedingRecord]?
    
    var shortId: String {
        return Pet.shortId(id)
    }
    
    var short: String {
        return "\(account).\(name)(\(shortId))"
    }
    
    var long: String {
        return "@\(alias)://\(account).\(name)(\(id))"
    }
   
    init(id: UUID, name: String, type: String, race: String, account: String, feeder: String, alias: String, role: Int) {
        self.id = id
        self.name = name
        self.type = race
        self.race = race
        self.account = account
        self.role = role
        self.feeder = feeder
        self.alias = alias
    }
    
    enum CodingKeys : String, CodingKey {
        case id
        case name
        case race
        case type
        case account
        case role
        case feeder
        case alias
        case feedingRecords = "feedingrecords"
    }
}

class SqlFeedingRecord: Decodable {
    var timestamp: Date
    var portion: Double
    var feeder: String
    var alias: String
    var name: String
}
