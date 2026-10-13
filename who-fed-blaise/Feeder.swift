//
//  Feeder.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 10.09.26.
//

import Foundation

class Feeder: Encodable, Decodable {
    var id: UUID
    var email: String
    var password: String
    var name: String
    var alias: String
    
    var shortId: String {
        return Feeder.shortId(id)
    }
    
    private static func shortId(_ id: UUID) -> String {
        return id.uuidString.split(separator: "-").first.map(String.init) ?? ""
    }
    
    var short: String {
        return Feeder.short(alias, id)
    }
    
    static func short(_ alias: String, _ id: UUID) -> String {
        return "\(alias)(\(Feeder.shortId(id)))"
    }
    
    var long: String {
        return Feeder.long(email,id)
    }

    static func long(_ email: String, _ id: UUID) -> String {
        return "\(email)(\(id))"
    }
    
    init(account: Account, id: UUID, email: String, password: String, name: String, alias: String) {
        self.id = id
        self.email = email
        self.password = password
        self.name = name
        self.alias = alias
    }
}

