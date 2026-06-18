//
//  PetPickerItem.swift
//  who-fed-blaise
//
//  Created by gude on 02.01.26.
//

import Foundation

class PetArray: Decodable, Encodable  {
    //static var logger: Logger = Logger(Logger.LEVEL_DEBUG, category: "PetArray")
    static let userDefaults: UserDefaults = .standard
    static let CURRENT_UNSET: Int = -1
    
    private let logger: Logger
    public let persistant: Bool
    public let name: String
    private(set) var current: Int = PetArray.CURRENT_UNSET
    private(set) var pets: [Pet] = []
    
    init(_ name: String, persistant: Bool) {
        self.name = name
        self.persistant = persistant
        self.logger = Logger(category: "PetArray(\(name))")
        restore()
    }
    
    private enum CodingKeys: String, CodingKey {
        case logger, persistant, name, current, pets
    }

    // We don't want to decode `fullName` from the JSON
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        current = try container.decode(Int.self, forKey: .current)
        pets = try container.decode([Pet].self, forKey: .pets)
        self.persistant = true
        self.logger = Logger(category: "PetArray(\(name))")
    }

    // But we want to store `fullName` in the JSON anyhow
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(current, forKey: .current)
        try container.encode(pets, forKey: .pets)
    }
    
    var isEmpty: Bool {
        return pets.count == 0
    }
    
    var isSingle: Bool {
        return pets.count == 1
    }
    
    var isMultiple: Bool {
        return pets.count > 1
    }
    
    private var count: Int {
        return pets.count
    }
    
    func removeAll() {
        pets.removeAll()
        current = PetArray.CURRENT_UNSET
        save()
    }
    
    private func exists(_ pet: Pet) -> Bool {
        return exists(pet.key)
    }
      
    private func exists(_ hostname: String, _ port: String, _ id: UUID, _ feeder: String) -> Bool {
        return exists(Key(hostname, port, id, feeder))
    }
    
    private func exists(_ key: Key) -> Bool {
        return exists(key.string)
    }
    
    private func exists(_ key: String) -> Bool {
        do {
            let index = try indexOf(key)
            return index>=0
        } catch {
            return false
        }
    }
    
    public func exists(_ id: UUID) -> Bool {
        if count == 0 {
            return false
        }
        do {
            let index = try indexOf(id)
            return index>=0
        } catch {
            return false
        }
    }
    
    private func indexOf(_ pet: Pet) throws -> Int {
        return try indexOf(pet.key)
    }
    
    private func indexOf(_ hostname: String, _ port: String, _ id: UUID, _ feeder: String) throws -> Int {
        return try indexOf(Key(hostname, port, id, feeder))
    }
    
    private func indexOf(_ key: Key) throws -> Int {
        return try indexOf(key.string)
    }
    
    private func indexOf(_ key: String) throws -> Int {
        logger.setMethod("indexOf(\(key))")
        if pets.count == 0 {
            logger.debug("empty array")
            throw PetArrayErrors.emptyPetList(name)
        } else {
            for index in 0...pets.count-1 {
                if pets[index].key.string == key {
                    logger.debug("found at index \(index)")
                    return index
                }
            }
        }
        logger.debug("not found")
        throw PetArrayErrors.unlistedPet("not found")
    }
    
    private func indexOf(_ id: UUID) throws -> Int {
        logger.setMethod("indexOf(\(id.uuidString))")
        let stringId = id.uuidString
        if pets.count == 0 {
            logger.debug("empty array")
            throw PetArrayErrors.unlistedPet("Index of pet \(stringId) in \(name); empty array")
        } else {
            for index in 0...pets.count-1 {
                if pets[index].id == id {
                    logger.debug("found at index \(index)")
                    return index
                }
            }
        }
        logger.debug("not found")
        throw PetArrayErrors.unlistedPet(stringId)
    }
    
    func get(_ pet: Pet) throws -> Pet {
        return try get(pet.key)
    }
    
    func get(_ hostname: String, _ port: String, _ id: UUID, _ feeder: String) throws -> Pet {
        return try get(Key(hostname, port, id, feeder))
    }
    
    func get(_ key: Key) throws -> Pet {
        return try get(key.string)
    }
    
    func get(_ key: String) throws -> Pet {
        logger.setMethod("get(\(key))")
        do {
            let index = try indexOf(key)
            return try get(index)
        } catch {
            logger.error("\(error)")
            throw error
        }
    }
    
    func get(_ id: UUID) throws -> Pet {
        logger.setMethod("get(\(id.uuidString))")
        do {
            let index = try indexOf(id)
            return try get(index)
        } catch {
            logger.error("\(error)")
            throw error
        }
    }
    
    func get(_ index: Int) throws -> Pet {
        if index >= 0 && index < pets.count {
            return pets[index]
        }
        throw PetArrayErrors.unlistedPet("index \(index) out of range 0..<\(pets.count)")
    }
    
    func setCurrent(_ pet: Pet) throws -> Pet {
        logger.setMethod("indexOf(\(pet.short)")
        if pets.count==0 {
            current=0
        }
        do {
            current=try indexOf(pet.id)
            logger.debug("Switch [\(current)]")
        } catch PetArrayErrors.unlistedPet {
            logger.debug("Override [\(current)]")
        }
        pets[current]=pet
        save()
        logger.info("Set [\(current)] : Success")
        return pet
    }

    public func setCurrent(hostname: String, port: String, id: UUID, feeder: String) throws -> Pet {
        let index  = try indexOf(Key(hostname, port, id, feeder))
        return try setCurrent(index)
    }

    public func setCurrent(key: Key) throws -> Pet {
        let index  = try indexOf(key)
        return try setCurrent(index)
    }

    public func setCurrent(keystring: String) throws -> Pet {
        let index  = try indexOf(keystring)
        return try setCurrent(index)
    }

    public func setCurrent(id: UUID) throws -> Pet {
        let index  = try indexOf(id)
        return try setCurrent(index)
    }

    public func setCurrent(up: Bool) throws -> Pet {
        if up==true {
            if current<count-1 {current = current+1}
            else {current = 0}
        } else {
            if current>0 {current = current-1}
            else {current = count-1}
        }
        save()
        return try getCurrentPet()
    }

    private func setCurrent(_ index: Int) throws -> Pet {
        logger.setMethod("setCurrent(\(index))")
        let pet = try get(index)
        self.current = index
        save()
        logger.info("[\(current)] = \(pet.short)")
        return pet
    }

    public func getCurrentPet() throws -> Pet {
        if current == PetArray.CURRENT_UNSET {
            throw PetArrayErrors.emptyPetList("No current pet; pet list [\(name)] is empty")
        }
        return try get(current)
    }

    public func removeCurrent() throws -> Pet {
        logger.setMethod("removeCurrent()")
        remove(try getCurrentPet())
        return try getCurrentPet()
    }
    
    func remove(_ pet: Pet) -> Void {
        remove(pet.key)
    }
    
    private func remove(_ key: Key) {
        remove(key.string)
    }
    
    private func remove(_ key: String) {
        logger.setMethod("remove(\(key))")
        do {
            let index = try indexOf(key)
            logger.debug("... at index \(index)")
            if current==index {
                if index>0 {
                    current = index-1
                } else {
                    current = count-2
                }
            } else if index<current {
                current=index-1
            }
            pets.remove(at: index)
            save()
        } catch {
            logger.error("\(error)")
        }
    }
    
    func append(_ pet: Pet) throws {
        logger.setMethod("append(\(pet.short)")
        do {
            let index = try indexOf(pet)
            logger.warn("Eexisting at index \(index)")
            return
        } catch {
            logger.debug("Does not exist)")
            pets.append(pet)
            if current == -1 {current=0}
            save()
            logger.info("Success at index \(pets.count-1)")
        }
    }
   
    public func string() throws -> String {
        let data = try Json.encoder.encode(self)
        guard let string = String(data: data, encoding: .utf8) else {
            throw PetArrayErrors.failedToEncode("Failed to stingify pet array \(name)")
        }
        return string
    }
    
    public func save() {
        logger.setMethod("save()")
        if !persistant {
            logger.debug("Not persistant")
            return
        }
        do {
            let string = try self.string()
            logger.debug("value is \(string)")
            PetArray.userDefaults.set(string, forKey: name)
        } catch {
            logger.error("\(error)")
        }
    }
    
    public func restore() {
        logger.setMethod("restore()")
        if !persistant {
            logger.debug("Not persistant")
            return
        }
        guard let string = PetArray.userDefaults.string(forKey: name) else {
            logger.warn("UserDefault forKey \(name) does not exist")
            return
        }
        logger.debug("UserDefauls[\(name)] = \(string)")
        guard let data = string.data(using: .utf8) else {
            logger.error("Failed to restore pet array \(name); failed converting string to data")
            return
        }
        do {
            let petArray = try Json.decoder.decode(PetArray.self, from: data)
            current = petArray.current
            pets = petArray.pets
            logger.info("Successfully restored")
            logger.debug("Restored \(try self.string())")
        } catch {
            logger.error("Failed to restore pet array \(name); \(error)")
        }
    }
}

