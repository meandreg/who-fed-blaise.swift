//
//  PetPickerItem.swift
//  who-fed-blaise
//
//  Created by gude on 02.01.26.
//

import Foundation

class Key: Decodable, Encodable {
    var hostname: String
    var port: String
    var id: UUID
    var feeder: String
    
    var shortId: String {
        return Pet.shortId(id)
    }

    var string: String {
        return Key.string(hostname,port,id,feeder)
    }
    
    static func string(_ hostname: String, _ port: String, _ id: UUID, _ feeder: String) -> String {
        return "\(hostname)_\(port)_\(id.uuidString.uppercased())_\(feeder)"
    }
    
    init(_ hostname: String, _ port: String, _ id: UUID, _ feeder: String) {
        self.hostname = hostname
        self.port = port
        self.id = id
        self.feeder = feeder
    }

    func setKey(hostname: String, port: String, id: UUID, feeder: String) {
        self.hostname = hostname
        self.port = port
        self.id = id
        self.feeder = feeder
    }
    
    
}

