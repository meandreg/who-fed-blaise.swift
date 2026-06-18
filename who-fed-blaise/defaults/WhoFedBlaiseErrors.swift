//
//  UserDefaultsError.swift
//  who-fed-blaise
//
//  Created by gude on 02.03.26.
//

enum UserDefaultsError: Error {
    case forKeyDoesNotExist(String)
    case failedToConvertToData(String)
    case failedToEncode(Encodable)
    //case failedToDecode(Decodable.self, Data)
}
