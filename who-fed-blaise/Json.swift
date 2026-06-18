//
//  Json.swift
//  who-fed-blaise
//
//  Created by gude on 10.06.26.
//

import Foundation

enum JsonErrors: Error {
    case failedToEncode(Encodable)
}

class Json {
    
    public static let encoder: JSONEncoder = initJsonEncoder()
    public static let decoder: JSONDecoder = initJsonDecoder()
    private static let logger:Logger = Logger(category: "Json")
    
    private static func initJsonEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }
        
    private static func initJsonDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
    
    public static func toData(_ encodable: Encodable) throws -> Data! {
        logger.setMethod("toData(...any Encodable...)")
        do {
            return try Json.encoder.encode(encodable)
        } catch {
            logger.error("\(error)")
            throw error
        }
    }
    
    public static func toString(encodable: Encodable) throws -> String {
        logger.setMethod("toString(...any Encodable...)")
        do {
            guard let string = String(data: try Json.toData(encodable), encoding: .utf8) else {
                logger.error("Failed to stringify")
                throw JsonErrors.failedToEncode(encodable)
            }
            return string
        } catch {
            logger.error("\(error)")
            throw error
        }
    }
}
