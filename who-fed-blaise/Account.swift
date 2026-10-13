//
//  Account.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 10.09.26.
//
import Foundation

class Account : Encodable, Decodable {
    var hostname: String
    var port: Int
    var id: UUID
    var name: String
    var alias: String
    
    var shortId: String {
        return Account.shortId(id)
    }
    
    private static func shortId(_ id: UUID) -> String {
        return id.uuidString.split(separator: "-").first.map(String.init) ?? ""
    }
    
    var short: String {
        return "\(alias)(\(shortId))"
    }
    
    var long: String {
        return Account.long(hostname,port,name)
    }

    static func long(_ hostname: String, _ port: Int, _ account: String) -> String {
        return "\(hostname):\(port)://\(account)"
    }

    init(hostname: String, port: Int, id: UUID, name: String, alias: String) {
        self.hostname = hostname
        self.port = port
        self.id = id
        self.alias = alias
        self.name = name
    }
}

