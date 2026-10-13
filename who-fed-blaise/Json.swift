//
//  Json.swift
//  who-fed-blaise
//
//  Created by gude on 10.06.26.
//

import Foundation

enum JsonErrors: Error {
    case failedToEncode(Encodable)
    case failedToDecode(Decodable)
    case failedToStringify(Encodable)
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
    
    public static func toData(encodable: Encodable) throws -> Data {
        logger.setMethod("toData(\(encodable.self))")
        do {
            let data = try Json.encoder.encode(encodable)
            logger.debug("Successfully encoded \(encodable)")
            return data
        } catch {
            logger.error("Failed to encode \(encodable) : \(error)")
            throw JsonErrors.failedToEncode(encodable)
        }
    }
    
    public static func toString(encodable: Encodable) throws -> String {
        logger.setMethod("toString(\(encodable.self))")
        do {
            let data = try Json.toData(encodable: encodable)
            guard let string = String(data: data, encoding: .utf8) else {
                logger.error("Failed to stringify")
                throw JsonErrors.failedToStringify(encodable)
            }
            logger.debug("Successfully stringified \(encodable)")
            return string
        } catch {
            logger.error("Failed to stringify \(encodable) : \(error)")
            throw JsonErrors.failedToStringify(encodable)
        }
    }
    
    public static func stringify(encodable: Encodable) -> String {
        logger.setMethod("stringify(\(encodable.self))")
        do {
            return try Json.toString(encodable: encodable)
        } catch {
            logger.error("Failed to stringify \(encodable) : \(error)")
            return "{'message':'Failed to stringify \(encodable) : \(error)'}"
        }
    }
}
