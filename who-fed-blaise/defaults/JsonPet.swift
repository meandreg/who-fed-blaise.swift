//
//  JsonPetParametersList.swift
//  who-fed-blaise
//
//  Created by gude on 08.12.25.
//
import Foundation

struct JsonPetList:Encodable, Decodable {
    var id: UUID
    var name: String
    var account: String
    var type: String
    var race: String
    var selected: Bool = false
}
