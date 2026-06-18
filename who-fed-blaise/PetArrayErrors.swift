//
//  UserDefaultsError.swift
//  who-fed-blaise
//
//  Created by gude on 02.03.26.
//
import Foundation

enum PetArrayErrors: Error {
    case failedToConvertToData(String)
    case failedToEncode(String)
    case unlistedPet(String)
    case isNotMultiple
    case indexOutofRange(String)
    case emptyPetList(String)
    case duplicatePetId(String)
}
