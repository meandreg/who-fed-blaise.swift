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
    
    convenience init(hostname: String, port: String, sqlPet: SqlPet) {
        self.init(hostname: hostname, port: port, id: sqlPet.id, name: sqlPet.name, type: sqlPet.type, race: sqlPet.race, account: sqlPet.account, feeder: sqlPet.feeder, alias: sqlPet.alias, role: sqlPet.role)
    }
    
    convenience init(_ jsonPet: JsonPet) {
        self.init(hostname: jsonPet.hostname, port: jsonPet.port, id: jsonPet.id, name: jsonPet.name, type: jsonPet.type, race: jsonPet.race, account: jsonPet.account, feeder: jsonPet.feeder, alias: jsonPet.alias, role: jsonPet.role)
    }
    
    func getKey() -> String {
        return WhoFedBlaiseViewModel.getKey(hostname, port, id, feeder)
    }
    
    static func exists(_ pet: Pet, in pets: [Pet]) -> Bool {
        return exists(pet.hostname, pet.port, pet.id, pet.feeder, in: pets)
    }
    
    static func exists(_ hostname: String, _ port: String, _ id: UUID, _ feeder: String, in pets: [Pet]) -> Bool {
        return exists(WhoFedBlaiseViewModel.getKey(hostname, port, id, feeder), in: pets)
    }
    
    static func exists(_ key: String, in pets: [Pet]) -> Bool {
        if pets.count == 0 {
            return false
        } else {
            for index in 0...pets.count-1 {
                if pets[index].getKey() == key {
                    return true
                }
            }
        }
        return false
    }
    
    static func indexOf(_ pet: Pet, in pets: [Pet]) throws -> Int {
        return try indexOf(pet.hostname, pet.port, pet.id, pet.feeder, in: pets)
    }
    
    static func indexOf(_ hostname: String, _ port: String, _ id: UUID, _ feeder: String, in pets: [Pet]) throws -> Int {
        return try indexOf(WhoFedBlaiseViewModel.getKey(hostname, port, id, feeder), in: pets)
    }
    
    static func indexOf(_ key: String, in pets: [Pet]) throws -> Int {
        if pets.count == 0 {
            throw WhoFedBlaiseErrors.emptyFeederPets
        } else {
            for index in 0...pets.count-1 {
                if pets[index].getKey() == key {
                    return index
                }
            }
        }
        throw WhoFedBlaiseErrors.notInPetList(key)
    }
    
    static func get(_ pet: Pet, in pets: [Pet]) throws -> Pet {
        return try get(pet.hostname, pet.port, pet.id, pet.feeder, in: pets)
    }
    
    static func get(_ hostname: String, _ port: String, _ id: UUID, _ feeder: String, in pets: [Pet]) throws -> Pet {
        return try get(WhoFedBlaiseViewModel.getKey(hostname, port, id, feeder), in: pets)
    }
    
    static func get(_ key: String, in pets: [Pet]) throws -> Pet {
        if pets.count == 0 {
            throw WhoFedBlaiseErrors.emptyPetList
        } else {
            for index in 0...pets.count-1 {
                if pets[index].getKey() == key {
                    return pets[index]
                }
            }
            throw WhoFedBlaiseErrors.notInPetList(key)
       }
    }
    
    static func remove(_ pet: Pet, in pets: inout [Pet]) throws -> Void {
        try remove(pet.getKey(), in: &pets)
    }
    
    static func remove(_ key: String, in pets: inout [Pet]) throws -> Void {
        do {
            let index = try indexOf(key, in: pets)
            pets.remove(at: index)
        } catch {
            throw WhoFedBlaiseErrors.notInPetList(key)
        }
    }
    
    static func append(_ pet: Pet, in pets: inout [Pet]) -> Int {
        do {
            return try indexOf(pet, in: pets)
        } catch {
            
        }
        if exists(pet, in: pets) {
            throw WhoFedBlaiseErrors.alreadyPartOfPetList(pet.getKey())
        } else {
            pets.append(pet)
            return pets.count-1
        }
    }
    
}

