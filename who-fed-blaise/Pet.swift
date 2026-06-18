//
//  PetPickerItem.swift
//  who-fed-blaise
//
//  Created by gude on 02.01.26.
//

import Foundation

class Pet: Identifiable, Decodable, Encodable {
    var hostname: String
    var port: String
    var id: UUID
    var name: String
    var type: String
    var race: String
    var account: String
    var feeder: String
    var alias: String
    var role: Int
    var feedingRecords: [FeedingRecord] = []
    
    var key: Key {
        return Key(hostname, port, id, feeder)
    }
    
    var shortId: String {
        return Pet.shortId(id)
    }
    
    static func shortId(_ id: UUID) -> String {
        return id.uuidString.split(separator: "-").first.map(String.init) ?? ""
    }
    
    var short: String {
        return "\(account).\(name)(\(shortId))"
    }
    
    static func short(_ account: String, _ name: String, _ id: UUID) -> String {
        return "\(account).\(name)(\(Pet.shortId(id)))"
    }
    
    var long: String {
        return Pet.long(hostname,port,alias,account,name,id)
    }

    static func long(_ hostname: String, _ port: String, _ alias: String, _ account: String, _ name: String, _ id: UUID) -> String {
        return "\(hostname):\(port)@\(alias)://\(account).\(name)(\(id))"
    }

    init(hostname: String, port: String, id: UUID, name: String, type: String, race: String, account: String, feeder: String, alias: String, role: Int) {
        self.hostname = hostname
        self.port = port
        self.id = id
        self.feeder = feeder
        self.alias = alias
        self.role = role
        self.name = name
        self.type = type
        self.race = race
        self.account = account
    }
    
    convenience init(_ jsonPet: JsonPet) {
        self.init(hostname: jsonPet.hostname, port: jsonPet.port, id: jsonPet.id, name: jsonPet.name, type: jsonPet.type, race: jsonPet.race, account: jsonPet.account, feeder: jsonPet.feeder, alias: jsonPet.alias, role: jsonPet.role)
    }
    
    var string: String {
        do {
            return try Json.toString(encodable: self)
        } catch {
            return ""
        }
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.hostname, forKey: .hostname)
        try container.encode(self.port, forKey: .port)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.race, forKey: .race)
        try container.encode(self.account, forKey: .account)
        try container.encode(self.feeder, forKey: .feeder)
        try container.encode(self.alias, forKey: .alias)
        try container.encode(self.role, forKey: .role)
        try container.encode(self.feedingRecords, forKey: .feedingRecords)
    }
}

