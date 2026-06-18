//
//  PetParameters.swift
//  who-fed-blaise
//
//  Created by gude on 01.12.25.
//

import Foundation
import UserNotifications
import Combine
import SwiftUI

class UserDefaultsPets {
    
    static let logger = Logger(Logger.PARAMETER_DEBUG, category: "UserDefaultPets")
    static let userDefaults: UserDefaults = .standard
    static let decoder = JSONDecoder()
    static let encoder = JSONEncoder()
    
    private static func toData(_ encodable: Encodable) -> Data! {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            return try encoder.encode(encodable)
        } catch {
            logger.error("\(error)")
            logger.error("Failed to encode petParametersList to data")
            return nil
        }
    }

    private static func toString(_ encodable: Encodable) -> String {
        guard let stringPets = String(data: toData(encodable), encoding: .utf8) else {
            logger.error("Failed to convert petParametersList data to String")
            return ""
        }
        return stringPets
    }

    private static func get(_ forKey: String) throws -> String {
        logger.debug("Get UserDefaults(\(forKey)) as a String")
        guard let string = userDefaults.string(forKey: forKey) else {
            logger.warn("UserDefault forKey \(forKey) does not exist")
            throw UserDefaultsError.forKeyDoesNotExist(forKey)
        }
        logger.debug("UserDefauls[\(forKey)] = \(string)")
        return string
    }
        
    private static func getData(_ forKey: String) throws -> Data  {
        logger.debug("Get UserDefaults(\(forKey)) as a Data")
        do {
            let string = try get(forKey)
            guard let data = string.data(using: .utf8) else {
                throw UserDefaultsError.failedToConvertToData(string)
            }
            return data
        } catch {
            throw error
        }
    }
    
    public static func getPet(_ id: UUID, whoFedBlaiseViewModel: WhoFedBlaiseViewModel) throws {
        logger.debug("Parse Data to JsonPetParameter")
        do {
            let data = try getData(id.uuidString)
            let jsonPetParameters = try UserDefaultsPets.decoder.decode(JsonPetParameters.self, from: data)
            logger.info("Successfully parsed data to \(jsonPetParameters)")
            WhoFedBlaiseViewModel.id = jsonPetParameters.id
            WhoFedBlaiseViewModel.name = jsonPetParameters.name
            whoFedBlaiseViewModel.feeder = jsonPetParameters.feeder
            whoFedBlaiseViewModel.account = jsonPetParameters.account
            whoFedBlaiseViewModel.hostname = jsonPetParameters.hostname
            whoFedBlaiseViewModel.port = jsonPetParameters.port
            whoFedBlaiseViewModel.log
            
            let pet = Pet(jsonPetParameters)
            pet.wallpaperImage = UserDefaultsPets.getWallpaperImage(pet)
            return pet
        } catch {
            logger.error("\(error)")
            logger.error("Failed to parse Data to JsonPetParameters")
            throw error
        }
    }
    
    public static func getPets() throws -> [UUID] {
        logger.debug("Get pet list")
        do {
            let data = try getData(Labels.PETLIST)
            let pets = try UserDefaultsPets.decoder.decode([UUID].self, from: data)
            logger.info("Successfully parsed data to \(pets)")
            return pets
        } catch {
            logger.error("\(error)")
            logger.error("Failed to parse Data to JsonPetParameters")
            throw error
        }
    }
    
    public static func save(_ pet: Pet, pets: [UUID]) throws -> Void {
        logger.debug("Save pet list to UserDefaults[\(Labels.PETLIST)]")
        save(pet)
        do {
            let data = try UserDefaultsPets.encoder.encode(pets+[pet.id])
            save(data, forKey: Labels.PETLIST)
        } catch {
            logger.error("\(error)")
            logger.error("Failed to encode petParametersList to data")
        }
    }
    
    private static func save(_ pet: Pet) {
        logger.debug("Save jsonPetParameters to UserDefaults[\(pet.id)]")
        do {
            let json = JsonPetParameters(pet)
            let data = try encoder.encode(json)
            save(data, forKey: pet.id.uuidString)
        } catch {
            logger.error("\(error)")
            logger.error("Failed to encode petParametersList to data")
        }
    }

    private static func save(_ data: Data, forKey key: String) {
        guard let string = String(data: data, encoding: .utf8) else {
            logger.error("Failed to convert petParametersList Data to String")
            return
        }
        save(string, forKey: key)
    }

    private static func save(_ string: String, forKey key: String) {
        logger.debug("Set UserDefaults[\(key)] = \(string)")
        userDefaults.set(string, forKey: key)
    }

    private static func getWallpaperPath(_ pet: Pet) -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(pet.id.uuidString + ".jpg")
    }

    private static func getWallpaperUIImage(_ pet: Pet) -> UIImage? {
        /*guard FileManager.default.fileExists(atPath: getWallpaperPath(pet).absoluteString) else {
            logger.warn("\(getWallpaperPath(pet)) does not exists")
            return nil
        }*/
        do {
            let uiImage = try Data(contentsOf: getWallpaperPath(pet))
            return UIImage(data: uiImage)
        } catch {
            logger.error("Error loading image from to \(getWallpaperPath(pet)) : \(error)")
        }
        return nil
    }
    
    public static func getWallpaperImage(_ pet: Pet) -> Image {
        guard let uiImageData = getWallpaperUIImage(pet) else {
            return Image(Defaults.WALLPAPERNAME)
        }
        return Image(uiImage: uiImageData)
    }
    
    public static func saveWallpaperUIImage(_ pet: Pet, uiImage: UIImage) {
        do {
            try uiImage.jpegData(compressionQuality: 0.8)?.write(to: getWallpaperPath(pet))
            logger.info("Save new UIImage to \(getWallpaperPath(pet))")
        } catch {
            logger.error("Failed to save UIImage to \(getWallpaperPath(pet)) : \(error)")
        }
        pet.wallpaperImage=getWallpaperImage(pet)
    }
}
