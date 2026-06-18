//
//  JsonPetParametersList.swift
//  who-fed-blaise
//
//  Created by gude on 08.12.25.
//
import Foundation

struct JsonPet:Encodable, Decodable {
    var id: UUID
    var name: String
    var type: String
    var race: String
    var account: String
    var feeder: String
    var alias: String
    var role: Int
    var hostname: String
    var port: String
    //var selected: Bool = false

    init(from: Pet) {
        self.id = from.id
        self.name = from.name
        self.type = from.type
        self.race = from.race
        self.account = from.account
        self.feeder = from.feeder
        self.alias = from.alias
        self.role = from.role
        self.hostname = from.hostname
        self.port = from.port
        //self.selected = from.selected
    }
    
    public static func initPets(from: [JsonPet]) -> [Pet] {
        var pets: [Pet] = []
        for jsonPet in from {
            pets.append(Pet(jsonPet))
        }
        return pets
    }
    
    public static func initJsonPets(from: WhoFedBlaiseViewModel) -> [JsonPet] {
        var jsonPets: [JsonPet] = []
        for pet in from.feederPets.pets {
            jsonPets.append(JsonPet(from: pet))
        }
        return jsonPets
    }
    
}
