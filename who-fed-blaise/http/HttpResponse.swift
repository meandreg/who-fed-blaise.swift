//
//  SqlResponse.swift
//  who-fed-blaise
//
//  Created by gude on 01.12.25.
//
import Foundation

class HttpResponse: Decodable {
    var returncode: Int = 0
    var message: String?
    var data: HttpResponseData
    static let logger:Logger = Logger(category: "HttpResponse")
    
    class HttpResponseData: Decodable {
        var request: HttpRequestBody
        var feeder: HttpFeeder
        var pets: [HttpPet]
    }

    class HttpAccount: Decodable {
        var id: UUID
        var name: String
        var alias: String
        var role: Int
    }
    
    class HttpFeeder: Decodable {
        var id: UUID
        var email: String
        var name: String
        var alias: String
        var role: Int
    }
        
    class HttpPet: Decodable {
        var id: UUID
        var name: String
        var type: String
        var race: String
        var role: Int
        var account: HttpAccount
        var feedingRecords: [HttpFeedingRecord]!
           
        enum CodingKeys : String, CodingKey {
            case id
            case name
            case role
            case race
            case type
            case account
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
    
    func getFeederPets() throws -> PetArray {
        HttpResponse.logger.setMethod("getFeederPets(...")
        let feederPets: PetArray = PetArray(Labels.FEEDERPETS,persistant: false)
        HttpResponse.logger.debug("\(data)")
        for httpPet in data.pets {
            HttpResponse.logger.debug("New pet \(httpPet.id)")
            let pet = pet(httpPet)
            do {
                try feederPets.append(pet)
            } catch {
                HttpResponse.logger.error("\(error)")
                throw error
            }
        }
        return feederPets
    }
    
    private func pet(_ httpPet: HttpPet) -> Pet
    {
        HttpResponse.logger.debug("New pet from \(httpPet)")
        let request = data.request
        let httpAccount = httpPet.account
        let account = Account(hostname: request.hostname, port: request.port, id: httpAccount.id, name: httpAccount.name, alias: httpAccount.alias)
        
        let httpFeeder = data.feeder
        let feeder = Feeder(account: account, id: httpFeeder.id, email: request.feeder, password: request.password,  name: httpFeeder.name, alias: httpFeeder.alias)
        
        let canFeed: Bool = canFeed(httpPet)
        let recordNumber: Int = recordNumber(httpPet)
        let pet = Pet(id: httpPet.id, name: httpPet.name, type: httpPet.type, race: httpPet.race, logLevel: request.logLevel, account: account, feeder: feeder, canFeed: canFeed, recordNumber: recordNumber, feedingRecords: getFeedingRecords(httpPet))
        
        HttpResponse.logger.debug("New pet : \(pet.string)")
        return pet
    }
    
    private func recordNumber (_ httpPet: HttpPet) -> Int {
        if httpPet.role == Role.PET_CHILD {
            return 1
        }
        return self.data.request.recordNumber ?? Int(Defaults.RECORDNUMBER)
    }
    
    private func canFeed (_ httpPet: HttpPet) -> Bool {
        let feeder = self.data.feeder
        if feeder.role != Role.ACCOUNT_USER {
            return true
        }
        if httpPet.account.role != Role.ACCOUNT_USER {
            return true
        }
        if httpPet.role != Role.PET_READONLY {
            return true
        }
        return false
    }
    
    private func canBeDeleted (_ httpPet: HttpPet, httpFeedingRecord: HttpFeedingRecord) -> Bool {
        let feeder = self.data.feeder
        if feeder.role != Role.ACCOUNT_USER {
            return true
        }
        let account = httpPet.account
        if account.role != Role.ACCOUNT_USER {
            return true
        }
        if feeder.email == httpFeedingRecord.feeder && httpPet.role == Role.PET_READONLY {
            return true
        }
        return false
    }
    
    private func getFeedingRecords(_ httpPet: HttpPet) -> [FeedingRecord] {
        var feedingRecords: [FeedingRecord] = []
        if httpPet.feedingRecords != nil {
            for httpFeedingRecord in httpPet.feedingRecords {
                let canbeBeDeleted = canBeDeleted(httpPet, httpFeedingRecord: httpFeedingRecord)
                feedingRecords.append(feedingRecord(httpFeedingRecord, canbeBeDeleted: canbeBeDeleted))
            }
        }
        return feedingRecords
    }
    
    private func feedingRecord(_ record: HttpFeedingRecord, canbeBeDeleted: Bool) -> FeedingRecord {
        return FeedingRecord(timestamp: record.timestamp, portion: record.portion, feeder: record.feeder, alias: record.alias, name: record.name, canBeDeleted: canbeBeDeleted)
    }
    
    func getFirstPet() throws -> Pet {
        HttpResponse.logger.setMethod("getFirstPet(...")
        guard let httpPet = self.data.pets.first else {
            throw HttpErrors.FaultyResponse("No pet in response")
        }
        let pet = pet(httpPet)
        HttpResponse.logger.info("... of \(pet.short)")
        HttpResponse.logger.debug("... \(pet.string)")
        return pet
    }
}
