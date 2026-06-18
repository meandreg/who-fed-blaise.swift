//
//  ViewModel.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 08.06.22.
//

import Foundation
import Combine
import UserNotifications
import BackgroundTasks
import SwiftUI

class FeederViewModel: ObservableObject {
    
    init() {
        do {
            self.pets = try UserDefaultsPets.getPets()
            if !self.pets.isEmpty {
                self.pet = try UserDefaultsPets.getPet(self.pets.first!)
                self.pets.removeFirst()
            }
        } catch {
            logger.error("Default pet used")
        }
    }
    
    //let userDefaultsPets: UserDefaultsPets
    let appname = Parameters.getAppName()
    
    @Published var pet: Pet = Pet()
    @Published var wallpaperMagnifyBy: Double = 1.0
    
    @Published var pets: [UUID] = []
    @Published var accountPicker: [AccountPickerItem] = []
    //@Published var accountPetIds: [UUID] = []
    //@Published var accountPetNames: [String] = []
    @Published var petPicker: [PetPickerItem] = []
    
    @Published var logLevel: String = Defaults.LOGLEVEL
    let logger = Logger(Defaults.LOGLEVEL, category: "FeedingViewModel")
    
    @Published var feedingEnabled: Bool = true
    @Published var feedingColor: Color = Labels.FEEDING_ENABLED
    @Published var statusMessage = ""
    
    let decoder: JSONDecoder = JSONDecoder()
    
    func addFeedingRecort(portion: Float) {
        if self.feedingEnabled {
            let current = Date()
            logger.debug("Add current time \(current)")
            guard let last = pet.feedingRecords.first?.timestamp  else {return}
            logger.debug("Last time \(last)")
            logger.debug("Interval \(current.timeIntervalSince(last))")
            guard current.timeIntervalSince(last)>60 else {return}
            self.feedingEnabled = false
            do {
                let httpRequestBody = HttpRequestBody.HttpRequestAddFeedingRecord(pet: pet, timestamp: current, portion: portion)
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                let httpBody = try encoder.encode(httpRequestBody)
                logger.debug("HttpRequestAddFeedingRecord = \(String(data: httpBody, encoding: .utf8)!)")
                dataTask(httpBody: httpBody)
            } catch {logger.error("\(error)")}
        }
    }
    
    func delFeedingRecord(feedingRecord: FeedingRecord) {
        do {
            let httpRequestBody = HttpRequestBody.HttpRequestDelFeedingRecord(pet: pet, timestamp: feedingRecord.timestamp)
            let httpBody = try JSONEncoder().encode(httpRequestBody)
            logger.debug("HttpRequestDelFeedingRecord = \(String(data: httpBody, encoding: .utf8)!)")
            dataTask(httpBody: httpBody)
        } catch {logger.error("\(error)")}
    }
    
    //@objc func get(_ pet: Pet) {
    func getFeedingRecords() {
        /*if pet.id == Defaults.ID {
            return
        }*/
        do {
            let httpRequestBody = HttpRequestBody.HttpRequestFeedingRecords(pet: pet)
            let httpBody = try JSONEncoder().encode(httpRequestBody)
            logger.debug("Get feeding records HttpBody = \(String(data: httpBody, encoding: .utf8)!)")
            dataTask(httpBody: httpBody)
        } catch {logger.error("\(error)")}
    }
    
    func getFeederAccounts() {
        do {
            let httpRequestBody = HttpRequestBody.HttpRequestFeederAccouns(pet: pet)
            let httpBody = try JSONEncoder().encode(httpRequestBody)
            logger.debug("Get feeder account HttpBody = \(String(data: httpBody, encoding: .utf8)!)")
            dataTask(httpBody: httpBody)
        } catch {logger.error("\(error)")}
    }
    
    func getAccountPets() {
        do {
            let httpRequestBody = HttpRequestBody.HttpRequestAccountPets(pet: pet)
            let httpBody = try JSONEncoder().encode(httpRequestBody)
            logger.debug("Get account pets HttpBody = \(String(data: httpBody, encoding: .utf8)!)")
            dataTask(httpBody: httpBody)
        } catch {logger.error("\(error)")}
    }

    func dataTask(httpBody: Data) {
        if let url = URL(string: pet.url+"/"+Labels.APPFEEDING+"/") {
            logger.info("dataTask URL is \(url.absoluteString)")
            var urlRequest: URLRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = httpBody
            let urlSession = URLSession.shared.dataTask(with: urlRequest, completionHandler: completionHandler)
            urlSession.resume()
        }
    }
    
    func completionHandler(data: Data?, response: URLResponse?, error: Error?) {
        guard checkResponse(data: data, response: response, error: error) else {return}
        decodeResponse(data: data!)
    }
    
    func checkResponse(data: Data?, response: URLResponse?, error: Error?) -> Bool {
        if let error = error {
            logger.error(error.localizedDescription)
            return false
        }
        guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
            logger.error("Returned 200...299 status code")
            return false
        }
        if let mimeType = response.mimeType, mimeType != "application/json" {
            logger.error("mimeType is \(mimeType)")
            return false
        }
        guard data != nil else {
            logger.error("Returned data is null")
            return false
        }
        return true
    }
    
    func decodeResponse(data: Data) {
        logger.debug("\(String(data: data, encoding: .utf8)!)")
        do {
            decoder.dateDecodingStrategy = .iso8601
            let sqlResponse = try decoder.decode(SqlResponse.self, from: data)
            logger.debug("sqlResponse.returncode: \(sqlResponse.returncode), sqlResponse.message: \(sqlResponse.message ?? "")")
            guard sqlResponse.returncode==0 else {
                logger.error("return code is not 0 : \(sqlResponse)")
                return
            }
            
            guard let data = sqlResponse.data else {
                logger.error("data object does not exists : \(sqlResponse)")
                return
            }
            
            if let pet = data.pet {
                logger.debug("sqlResponse.pet: \(pet)")
                dispatch(pet)
            } else if let feederAccounts = data.feederaccounts {
                logger.debug("sqlResponse.feederaccounts: \(feederAccounts)")
                dispatch(feederAccounts)
            } else if let accountPets = data.accountpets {
                logger.debug("sqlResponse.accountpets: \(accountPets)")
                dispatch(accountPets)
            }
        } catch {
            logger.error("\(error)")
            dispatch()
        }
    }
    
    func enableFeeding() {
        guard self.feedingEnabled else {
            self.feedingEnabled = true
            return
        }
    }
        
    func dispatch() {
        DispatchQueue.main.async {
            self.logger.error("Failed to return data from remote server")
            self.enableFeeding()
        }
    }
    
    func dispatch(_ sqlFeederAccounts: SqlFeederAccounts) {
        DispatchQueue.main.async {
            if sqlFeederAccounts.accounts.count==0 {
                self.resetFeederAccounts()
                return
            }
            self.accountPicker.removeAll()
            sqlFeederAccounts.accounts.forEach({account in
                self.accountPicker.append(AccountPickerItem(id: account))
            })
            var keepAccount: Bool = false
            for item in self.accountPicker where item.id==self.pet.account {
                keepAccount=true
            }
            if !keepAccount {
                self.pet.account=self.accountPicker.first!.id
            }
        }
    }

    func resetFeederAccounts() {
        pet.account=Defaults.ACCOUNT
        accountPicker=[]
        resetAccountPets()
    }
    

    func dispatch(_ sqlAccountPets: SqlAccountPets) {
        self.logger.debug("Pets of account \(sqlAccountPets.account) : \(sqlAccountPets.pets.count)")
        DispatchQueue.main.async {
            if sqlAccountPets.pets.count==0 {
                self.resetAccountPets()
                return
            }
            self.petPicker.removeAll()
            sqlAccountPets.pets.forEach({pet in
                self.petPicker.append(PetPickerItem(id: pet.id, name: pet.name))
            })
            var keepPet: Bool = false
            for pet in sqlAccountPets.pets where pet.id==self.pet.id {
                keepPet = true
            }
            if !keepPet {
                let pet = self.petPicker.first!
                self.pet.id=pet.id
                self.pet.name=pet.name
            }
        }
    }
    
    func resetAccountPets() {
        pet.id=UUID()
        pet.name=Defaults.PETNAME
        petPicker = []
    }
    
    func dispatch(_ sqlPet: SqlPetFeedingRecords) {
        DispatchQueue.main.async {
            self.pet.name = sqlPet.name
            self.pet.account = sqlPet.account
            self.pet.feedingRecords = sqlPet.feedingrecords
            self.enableFeeding()
        }
    }

    /*func requestNotification() {
     
     UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
     UNUserNotificationCenter.current().removeAllDeliveredNotifications()
     logger.debug("Existing notifications cancelled")
     
     if feedingRecords.isEmpty {
     return
     }
     
     let feedingNextInSeconds = feedingNext*60
     logger.debug("Next feeding : \(feedingNext) minutes")
     let feedingStart :Date = (feedingRecords.first?.timestamp.addingTimeInterval(Double(feedingNextInSeconds)))!
     logger.info("Next feeding at \(DateFormatters.anyDateFormatter.string(from: feedingStart))")
     let content = UNMutableNotificationContent()
     content.title = "Ne m'oublie pas à \(DateFormatters.HHmmFormatter.string(from: feedingStart))"
     content.subtitle = "... et aussi mettre who-fed-blaise à jour"
     content.sound = UNNotificationSound.default
     
     var before = notifyBefore
     while before > 0 {
     let timeInterval :TimeInterval = Double(Int(feedingNext)-Int(before))*60 // Time interval in second
     let notificationStart :Date = (feedingRecords.first?.timestamp.addingTimeInterval(timeInterval))!
     logger.debug("Notification at \(DateFormatters.anyDateFormatter.string(from: notificationStart))")
     let dateComponents :DateComponents = Calendar.current.dateComponents([.hour, .minute], from: notificationStart)
     let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
     let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
     UNUserNotificationCenter.current().add(request)
     before = before - notifyEvery
     }
     }
     
     func scheduleAppRefresh() {
     let request = BGAppRefreshTaskRequest(identifier: "eu.meandre.who-fed-blaise.refresh")
     // Fetch no earlier than 15 minutes from now.
     request.earliestBeginDate = Date(timeIntervalSinceNow: 60)
     
     do {
     try BGTaskScheduler.shared.submit(request)
     } catch {
     print("Could not schedule app refresh: \(error)")
     }
     }
     
     
     func setFeedingData(cloudantFeedingData: SqlFeedingData) {
     var feedingRecords: [FeedingRecord] = []
     for cloudantFeedingRecord in cloudantFeedingData.records {
     let feedingRecord = FeedingRecord(timestamp: cloudantFeedingRecord.timestamp, feeder: cloudantFeedingRecord.feeder, alias: cloudantFeedingRecord.alias, portion: cloudantFeedingRecord.portion)
     feedingRecords.append(feedingRecord)
     }
     self.feedingRecords = feedingRecords
     }
     
    
    func setWallpaperImage(key: UUID, image: UIImage) {
        setWallpaperUIImage(image)
    }
    */
    func addPet() {
        logger.info("ADD NEW PET")
        let newPet = Pet(pet)
        pets.append(pet.id)
        pet=newPet
        savePets()
    }
    
    func removePet() {
        logger.info("REMOVE PET")
        if pets.count > 1 {
            do {
                pet = try UserDefaultsPets.getPet(self.pets[1])
                pets.remove(at: 0)
            } catch {
                statusMessage = "Failed to remove pet : \(error.localizedDescription)"
                logger.error(statusMessage)
            }
        }
    }
    
    func savePets() {
        logger.info("SAVE PET LIST")
        do {
            try UserDefaultsPets.save(pet, pets: pets)
            statusMessage = "Successfully saved pet list"
        } catch {
            statusMessage = "Failed to save pet list : \(error.localizedDescription)"
        }
    }
    
    /*func savePet() {
        logger.info("SAVE PET \(pet.id)")
        UserDefaultsPets.save(pet)
        statusMessage = "Successfully saved \(pet.name)"
    }*/
    
    func swipe(right: Bool) {
        logger.info("SWIPE PET RIGHT : \(right)")
        if pets.isEmpty {
            statusMessage = "No pet swipe"
        }
        if right {
            swap(newIndex: 0, oldIndex: pets.count-1)
        } else {
            swap(newIndex: pets.count-1, oldIndex: 0)
        }
    }
    
    func swap(newIndex: Int, oldIndex: Int) {
        do {
            let id = self.pets[newIndex]
            let pet = try UserDefaultsPets.getPet(id)
            self.pets.remove(at: newIndex)
            self.pets.insert(self.pet.id, at: oldIndex)
            self.pet = pet
        } catch {
            self.statusMessage = "Failed to swap current pet with pet at index : \(oldIndex)"
            logger.debug(statusMessage)
        }
    }
    /*
    private func getWallpaperPath() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(pet.id.uuidString + ".jpg")
    }

    private func getWallpaperUIImage() -> UIImage? {
        guard FileManager.default.fileExists(atPath: getWallpaperPath().absoluteString) else {
            logger.warn("\(getWallpaperPath()) does not exists")
            return nil
        }
        do {
            let uiImage = try Data(contentsOf: getWallpaperPath())
            return UIImage(data: uiImage)
        } catch {
            logger.error("Error loading image from to \(getWallpaperPath()) : \(error)")
        }
        return nil
    }
    
    public func getWallpaperImage() -> Image {
        guard let uiImageData = getWallpaperUIImage() else {
            return Image(Defaults.WALLPAPERNAME)
        }
        return Image(uiImage: uiImageData)
    }
    
    public func setWallpaperUIImage(uiImage: UIImage) {
        do {
            try uiImage.jpegData(compressionQuality: 0.8)?.write(to: getWallpaperPath())
            logger.info("Save new UIImage to \(getWallpaperPath())")
        } catch {
            logger.error("Failed to save UIImage to \(getWallpaperPath()) : \(error)")
        }
    }
    */
}
