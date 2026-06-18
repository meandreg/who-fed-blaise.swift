//
//  UserDefaultsError.swift
//  who-fed-blaise
//
//  Created by gude on 02.03.26.
//
import Foundation

enum WhoFedBlaiseErrors: Error {
    case propertyIsMissing(String)
    case forKeyDoesNotExist(String)
    case imageDoesNotExist(String)
    case failedToConvertToData(String)
    case failedToEncode(Encodable)
    case unknownPet(String)
    case alreadyPartOfPetList(String)
    case alreadySelectedPet(String)
    case isDefaultPet
    case isNotMultiple
    case indexOutofRange(String)
    case emptyPetList(String)
    case notInSelectedPets(String)
    case notInFeederPets(String)
    case notInPetList(String)
}
