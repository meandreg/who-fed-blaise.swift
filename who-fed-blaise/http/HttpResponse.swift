//
//  SqlResponse.swift
//  who-fed-blaise
//
//  Created by gude on 01.12.25.
//
import Foundation

enum HtttpResponseErrors: Error {
    case invalidUpdatedPet(HttpResponse)
    case invalidFeederPets(HttpResponse)
    case invalidPet(HttpResponse)
}

class HttpResponse: Decodable {
    var returncode: Int = 0
    var message: String?
    var data: HttpResponseData?
    static let logger:Logger = Logger(category: "HttpResponse")
    
    class HttpResponseData: Decodable {
        var action: String
        var feeder: String?
        var account: String?
        var feederpets: [HttpPet]?
        var pet: HttpPet?
        var updatedpet: UpdatedPet?
    }

    class UpdatedPet: Decodable {
        var pet: UUID
    }
    
    class HttpPet: Decodable {
        var id: UUID
        var name: String
        var type: String
        var race: String
        var account: String
        var feeder: String
        var alias: String
        var role: Int
        var feedingRecords: [HttpFeedingRecord]?
       
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

    class HttpFeedingRecord: Decodable {
        var timestamp: Date
        var portion: Double
        var feeder: String
        var alias: String
        var name: String
    }
    
    func getUpdatedPetId() throws -> UUID {
        if let updatedPet = self.data?.updatedpet {
            return updatedPet.pet
        }
        throw HtttpResponseErrors.invalidUpdatedPet(self)
    }

    func getFeederPets(hostname: String, port: String) throws -> PetArray {
        HttpResponse.logger.setMethod("getFeederPets(...")
        if let httpFeederPets = self.data?.feederpets {
            let feederPets: PetArray = PetArray(Labels.FEEDERPETS,persistant: false)
            for httpPet in httpFeederPets {
                let pet = try getPet(hostname: hostname, port: port, pet: httpPet)
                do {
                    try feederPets.append(pet)
                } catch {
                    HttpResponse.logger.error("\(error)")
                    throw error
                }
            }
            return feederPets
        }
        throw HtttpResponseErrors.invalidFeederPets(self)
    }

    func getPet(hostname: String, port: String, pet: HttpPet) throws -> Pet {
        return Pet(hostname: hostname, port: port, id: pet.id, name: pet.name , type: pet.type, race: pet.race, account: pet.account, feeder: pet.feeder, alias: pet.alias, role: pet.role)
    }
    
    func getFeedingRecord(record: HttpFeedingRecord) -> FeedingRecord {
        return FeedingRecord(timestamp: record.timestamp, portion: record.portion, feeder: record.feeder, alias: record.alias, name: record.name)
    }
    
    func getFeedingRecords(hostname: String, port: String) throws -> Pet {
        HttpResponse.logger.setMethod("getFeedingRecords(...")
        if let httpPet = self.data?.pet {
            HttpResponse.logger.setMethod("dispatchFeedingRecords()")
            let pet: Pet = try getPet(hostname: hostname, port: port, pet: httpPet)
            if let httpFeedingRecords = self.data?.pet?.feedingRecords {
                for httpFeedingRecord in httpFeedingRecords {
                    let feedingRecord = getFeedingRecord(record: httpFeedingRecord)
                    pet.feedingRecords.append(feedingRecord)
                }
            }
            HttpResponse.logger.info("... of \(pet.short)")
            HttpResponse.logger.debug("... \(pet.string)")
            return pet
        }
        throw HtttpResponseErrors.invalidPet(self)
    }
}
