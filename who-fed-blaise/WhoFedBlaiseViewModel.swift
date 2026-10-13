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
import PhotosUI

class WhoFedBlaiseViewModel: ObservableObject {
    
    //@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    static let portionFull:String = if #available(iOS 17, *) {"battery.100percent"} else {"rectangle.fill"}
    static let portionHalf:String = if #available(iOS 17, *) {"battery.50percent"} else {"rectangle.lefthalf.filled"}
    
    static var deviceToken: String = WhoFedBlaiseDefaults.restoreDeviceToken()
    
    init() {
        logger.setMethod("init()")
        if !selectedPets.isEmpty {
            for pet in selectedPets {
                getLastUpdated(pet)
            }
            //self.selectedPetConfig = false
        }
        AppDelegate.shared.whoFedBlaiseViewModel = self
    }
    
    //let appDelegate: AppDelegate
    //var deviceToken: String = Defaults.DEVICETOKEN
    @Published var hostname: String = Defaults.HOSTNAME
    @Published var port: String = Defaults.PORT
    @Published var feeder: String = Defaults.FEEDER
    @Published var alias: String = Defaults.ALIAS
    @Published var id: UUID = UUID()
    //@Published var key: Key!
    
    @Published var password: String = Defaults.PASSWORD
    //@Published var role: Int = Role.PET_READONLY
    var canFeed: Bool = false

    @Published var account: String = Defaults.ACCOUNT
    @Published var name: String = Defaults.PETNAME
    @Published var type: String = Defaults.PETTYPE
    @Published var race: String = Defaults.PETRACE
    @Published var feedingRecords: [FeedingRecord] = []
    
    @Published var recordNumber: Float = Defaults.RECORDNUMBER
    @Published var feedingNext :Float = Defaults.FEEDINGNEXT
    @Published var feedingNextUnit :Float = Defaults.FEEDINGNEXT
    @Published var notifyBefore :Float = Defaults.NOTIFYBEFORE
    @Published var notifyEvery :Float = Defaults.NOTIFYEVERY
    
    @Published var wallpaperImage: Image = Image(Defaults.WALLPAPERNAME)
    @Published var wallpaperMagnifyBy: Double = Defaults.WALLPAPERMAGNIFYBY
    @Published var wallpaperOffsetWidth: Double = Defaults.WALLPAPEROFFSETWIDTH
    @Published var wallpaperOffsetHeight: Double = Defaults.WALLPAPEROFFSETHEIGHT
    
    @Published var fontsizePetName: CGFloat = Defaults.FONTSIZE_PETNAME
    @Published var fontsizePetAccount: CGFloat = Defaults.FONTSIZE_PETACCOUNT
    @Published var fontsizeTimestamp: CGFloat = Defaults.FONTSIZE_TIMESTAMP
    @Published var fontsizeFeeder: CGFloat = Defaults.FONTSIZE_FEEDER
    @Published var fontsizeFooter: CGFloat = Defaults.FONTSIZE_FOOTER
    
    @Published var foregroundColor: Int = Defaults.FOREGROUNDCOLOR
    @Published var backgroundColor: Int = Defaults.BACKGROUNDCOLOR
    @Published var opacity: Float = Defaults.OPACITY
    
    @Published var feederPets: PetArray = PetArray(Labels.FEEDERPETS,persistant: false)
    @Published var selectedPets: PetArray = PetArray(Labels.SELECTEDPETS,persistant: true)
    @Published var selectedPetPicker: Bool = false
    @Published var selectedPetConfig: Bool = true
    @Published var selectedPetPhoto: Bool = false
    
    @Published var feedingEnabled: Bool = true
    @Published var feedingColor: Color = Labels.FEEDING_ENABLED

    @Published var statusMessage = ""
    @Published var logLevel: String = Defaults.LOGLEVEL
    private let logger = Logger(category: "WhoFedBlaiseViewModel")
    //private static var LOGLEVEL: Int = Defaults.LOGLEVEL
    
    var intPort: Int {
        return Int(port) ?? 80
    }
    var key: Key {
        return Key(self.hostname,self.intPort,self.id,self.feeder)
    }
    
    var shortId: String {
        return Pet.shortId(id)
    }
    
    var short: String {
        return Pet.short(account,name,id)
    }
    
    var long: String {
        return Pet.long(hostname,intPort,alias,account,name,id)
    }
    
    private func set(_ pet: Pet) {
        logger.setMethod("set(\(pet.short))")
        let feeder = pet.feeder
        let account = pet.account
        self.setLogLevel(pet.logLevel)
        self.hostname = account.hostname
        self.port = String(account.port)
        self.feeder = feeder.email
        self.password = feeder.password
        self.id = pet.id
        resetWallpaper()
        resetFeedingRecords()
        restore()
        self.name = pet.name
        self.account = account.alias
        self.race = pet.race
        self.type = pet.type
        self.canFeed = false
        save()
        getFeedingRecords()
        logger.debug(self.string)
    }
    
    public func setLogLevel(_ level: String) {
        logger.setMethod("setLogLevel(\(level))")
        Logger.setLevel(level)
    }
    
    private func resetWallpaper() {
        wallpaperImage = Image(Defaults.WALLPAPERNAME)
        wallpaperMagnifyBy = Defaults.WALLPAPERMAGNIFYBY
        wallpaperOffsetWidth = Defaults.WALLPAPEROFFSETWIDTH
        wallpaperOffsetHeight = Defaults.WALLPAPEROFFSETHEIGHT
    }

    private func resetFeedingRecords() {
        self.feedingRecords = []
    }

    func addFeedingRecord(portion: Float) {
        logger.setMethod("addFeedingRecord(\(portion))")
        if self.feedingEnabled {
            let current = Date()
            logger.debug("Add current time \(current)")
            if let last = feedingRecords.first?.timestamp  {
                logger.debug("Last time \(last)")
                logger.debug("Interval \(current.timeIntervalSince(last))")
                guard current.timeIntervalSince(last)>60 else {return}
            }
            self.feedingEnabled = false
            let request = HttpRequestBody.HttpRequestAddFeedingRecord(self, timestamp: current, portion: portion)
            dataTask(request: request, completionHandler: feedingRecordsCompletionHandler)
        }
    }
    
    func delFeedingRecord(feedingRecord: FeedingRecord) {
        logger.setMethod("delFeedingRecord(\(feedingRecord))")
        let request = HttpRequestBody.HttpRequestDelFeedingRecord(self, timestamp: feedingRecord.timestamp)
        dataTask(request: request, completionHandler: feedingRecordsCompletionHandler)
    }
    
    //@objc func get(_ pet: Pet) {
    func getFeedingRecords() {
        logger.setMethod("getFeedingRecords()")
        let request = HttpRequestBody.HttpRequestFeedingRecords(self)
        dataTask(request: request, completionHandler: feedingRecordsCompletionHandler)
    }
    
    func getFeederPets() {
        logger.setMethod("getFeederPets()")
        if feeder == Defaults.FEEDER {return}
        let request = HttpRequestBody.HttpRequestFeederPets(self)
        dataTask(request: request, completionHandler: feederPetsCompletionHandler)
    }

    func getLastUpdated(_ pet: Pet) {
        logger.setMethod("getLastpdated(\(pet.short))")
        if pet.feeder.email == Defaults.FEEDER {return}
        let request = HttpRequestBody.HttpRequestLastUpdated(pet)
        dataTask(request: request, completionHandler: lastUpdatedCompletionHandler)
    }

    func dataTask(request: HttpRequestBody, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        logger.setMethod("datatask(\(request))")
        guard let url = URL(string: Defaults.PROTOCOL+"://"+request.hostname+":"+String(request.port)+"/"+Labels.APPFEEDING+"/") else {
            logger.error("Failed to initiate URL")
            return
        }
        logger.debug("URL is \(url.absoluteString)")
        var urlRequest: URLRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            let body = try Json.encoder.encode(request)
            logger.debug("HttpBody = \(String(data: body, encoding: .utf8)!)")
            urlRequest.httpBody = body
        } catch {
            logger.error("Failed to encode request : \(error)")
            return
        }
        let urlSession = URLSession.shared.dataTask(with: urlRequest, completionHandler: completionHandler)
        urlSession.resume()
    }
    
    /*func completionHandler(data: Data?, response: URLResponse?, error: Error?) {
        guard checkResponse(data: data, response: response, error: error) else {return}
        decodeResponse(data: data!)
    }*/
    
    func throwFaultyResponse(_ message : String) -> Error {
        logger.error(message)
        return HttpErrors.FaultyResponse(message)
    }
    
    func checkResponse(data: Data?, response: URLResponse?, error: Error?) throws -> Data {
        logger.setMethod("checkResponse(...))")
        if let error = error {
            throw throwFaultyResponse("\(error.localizedDescription)")
        }
        guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
            throw throwFaultyResponse("Returned 200...299 status code")
        }
        if let mimeType = response.mimeType, mimeType != "application/json" {
            throw throwFaultyResponse("mimeType is \(mimeType)")
        }
        guard (data != nil) else {
            throw throwFaultyResponse("Returned data is null")
        }
        return data!
    }
    
    func decodeResponse(data: Data) throws -> HttpResponse {
        logger.setMethod("decodeResponse(data))")
        logger.debug("\(String(data: data, encoding: .utf8)!)")
        let response = try Json.decoder.decode(HttpResponse.self, from: data)
        logger.debug("httpResponse.returncode: \(response.returncode), httpResponse.message: \(String(describing: response.message))")
        guard response.returncode==0 else {
            throw throwFaultyResponse("return code is not 0 : \(response)")
        }
        return response
    }
    
    func enableFeeding() {
        guard self.feedingEnabled else {
            self.feedingEnabled = true
            return
        }
    }

    func feederPetsCompletionHandler(data: Data?, response: URLResponse?, error: Error?) -> Void {
        logger.setMethod("feederPetsCompletionHandler(...)")
        do {
            let data: Data = try checkResponse(data: data, response: response, error: error)
            let response = try decodeResponse(data: data)
            let feederPets = try response.getFeederPets()
            feederPetsDispatch(feederPets)
        } catch HttpErrors.FaultyResponse(String: ) {
            return
        } catch {
           logger.error("\(error)")
        }
    }

    func feederPetsDispatch(_ feederPets0: PetArray) {
        logger.setMethod("dispatchFeederPets(...)")
        DispatchQueue.main.async {
            let feederPets1 = PetArray(Labels.FEEDERPETS,persistant: false)
            if feederPets0.isEmpty {
                self.logger.warn("FeederPets list is empty")
                return
            }
            for pet in feederPets0.pets {
                do {
                    try feederPets1.append(pet)
                } catch {
                    self.logger.error("Failed to add \(pet.short) to \(feederPets1.name); \(error)")
                }
                if self.id == pet.id {
                    self.swapTo(pet.id)
                }
            }
           self.logger.info("Re-initiliazed Pet list \(self.feederPets.name)")
            self.logger.debug("Re-initiliazed Pet list \(self.feederPets.name) : \(self.feederPets.string)")
        
            if !feederPets1.isEmpty {
                if self.selectedPets.isEmpty {
                    do {
                        let pet = try feederPets1.get(0)
                        try self.selectedPets.append(pet)
                        self.switchTo(pet.id)
                    } catch {
                        self.logger.error("Failed to get(0) from \(feederPets1.name); \(error)")
                    }
                }
            }
            self.feederPets = feederPets1
        }
    }

    func feedingRecordsCompletionHandler(data: Data?, response: URLResponse?, error: Error?) -> Void {
        logger.setMethod("feedingRecordsCompletionHandler(...)")
        do {
            let data: Data = try checkResponse(data: data, response: response, error: error)
            let response = try decodeResponse(data: data)
            let pet = try response.getFirstPet()
            dispatchPetFeedingRecords(pet)
        } catch HttpErrors.FaultyResponse {
            return
        } catch {
           logger.error("\(error)")
        }
    }

    func dispatchPetFeedingRecords(_ pet: Pet) {
        logger.setMethod("dispatchFeedingRecords(\(Pet.shortId(id)))")
        DispatchQueue.main.async {
            self.feedingEnabled = true
            self.id = pet.id
            self.name = pet.name
            self.account = pet.account.alias
            self.feeder = pet.feeder.email
            self.alias = pet.feeder.alias
            self.type = pet.type
            self.race = pet.race
            self.name = pet.name
            self.canFeed = pet.canFeed
            self.recordNumber = Float(pet.recordNumber)
            self.feedingRecords = pet.feedingRecords
            self.logger.info("... of \(self.short)")
            self.logger.debug("... \(self.string)")
        }
    }
    
    func lastUpdatedCompletionHandler(data: Data?, response: URLResponse?, error: Error?) -> Void {
        logger.setMethod("lastUpdatedCompletionHandler(...)")
        do {
            let data: Data = try checkResponse(data: data, response: response, error: error)
            let response = try decodeResponse(data: data)
            let pet = try response.getFirstPet()
            dispatchLastUpdated(pet: pet)
        } catch HttpErrors.FaultyResponse {
            return
        } catch {
           logger.error("\(error)")
        }
    }

    func dispatchLastUpdated(pet : Pet) {
        DispatchQueue.main.async {
            self.logger.setMethod("dispatchLastUpdated(\(pet.short))")
            do {
                let selectedPet = try self.selectedPets.get(pet)
                self.logger.debug("\(pet.short) found in selected pet list")
                let record = pet.feedingRecords.first ?? FeedingRecord(timestamp: Date.distantPast, portion: Double(Defaults.PORTION), feeder: pet.feeder)
                self.logger.debug("First record is \(record.string))")
                selectedPet.feedingRecords = [record]
            } catch {
                self.logger.error("Unselected pet\(pet.short)")
                return
            }
            
            var latestTimestamp: Date = .distantPast
            var latestPet: UUID = UUID()
            for pet in self.selectedPets.pets {
                do {
                    let timestamp: Date = try pet.lastUpdated()
                    if latestTimestamp < timestamp {
                        latestTimestamp = timestamp
                        latestPet = pet.id
                        self.logger.debug("Pet \(pet.short) was last set at \(latestTimestamp)")
                    }
                } catch {
                    self.logger.debug("Pet \(pet.short) has no feeding records")
                    return
                }
            }
            
            self.switchTo(latestPet)
            self.selectedPetConfig = false
        }
    }
    
    func swipe(right: Bool)  {
        logger.setMethod("swipe(\(right))")
        do {
            set(try selectedPets.setCurrent(up: right))
            self.logger.info("... to \(self.short)")
        } catch {
            logger.error("\(error)")
        }
    }
    
    func swapTo(_ id: UUID) {
        logger.setMethod("swapTo(\(id.uuidString))")
        do {
            let current = try selectedPets.getCurrentPet()
            logger.debug("from \(current.id.uuidString)")
            let target = try feederPets.get(id)
            logger.debug("from \(current.short) to \(target.short)")
            if !(current.key.string==target.key.string) {
                WhoFedBlaiseDefaults.remove(current.key)
                set(try selectedPets.setCurrent(target))
            }
            logger.info("Success")
        } catch {
            logger.error("\(error)")
        }
    }
    
    func switchTo(_ id: UUID) {
        logger.setMethod("switchTo(\(id.uuidString))")
        do {
            set(try selectedPets.setCurrent(id: id))
        } catch {
            logger.error("\(error)")
        }
    }
    
    func addFeederPet() {
        logger.setMethod("addFeederPet()")
        do {
            for pet in feederPets.pets {
                if !selectedPets.exists(pet.id)  {
                    try selectedPets.append(pet)
                    set(try selectedPets.setCurrent(pet))
                    logger.info("Pet \(pet.short) added")
                    return
                }
            }
        } catch {
            logger.warn("\(error)")
        }
    }
    
    func removeCurrentPet() {
        logger.setMethod("removeCurrentPet()")
        do {
            WhoFedBlaiseDefaults.remove(key)
            set(try selectedPets.removeCurrent())
        } catch {
            logger.error("\(error)")
        }
    }
    
    private func fontsize(target: inout CGFloat, increase: Bool) {
        let scale:CGFloat = 2
        if increase {
            target=target+scale
        } else {
            target=target-scale
        }
        save()
    }
    
    func fontsizeHeader(increase: Bool) {
        logger.setMethod("fontsizeHeader(\(increase))")
        fontsize(target: &fontsizePetName, increase: increase)
        fontsize(target: &fontsizePetAccount, increase: increase)
        fontsize(target: &fontsizeFooter, increase: increase)
        logger.debug("Header font size: \(fontsizePetName), \(fontsizePetAccount), \(fontsizeFooter)")
    }
    
    func fontsizeRecord(increase: Bool) {
        logger.setMethod("fontsizeRecord(\(increase))")
        fontsize(target: &fontsizeTimestamp, increase: increase)
        fontsize(target: &fontsizeFeeder, increase: increase)
        logger.debug("Record font size: \(fontsizeTimestamp), \(fontsizeFeeder)")
    }
    
    var string: String {
        do {
            let encodable = JsonPetParameters(self)
            let string = try Json.toString(encodable: encodable)
            return string
        } catch {
            let message = String("\(error)")
            logger.error(message)
            return String(message)
        }
    }
    
    func save() {
        logger.setMethod("save()")
        if selectedPets.isEmpty {
            logger.warn("Failed to save; No selected pet")
            return
        }
        
        let keyString = key.string
        logger.info("Save current pet to UserDefaults[\(keyString)]")
        do {
            let json = JsonPetParameters(self)
            let data = try Json.toData(encodable: json)
            WhoFedBlaiseDefaults.save(data, forKey: keyString)
        } catch {
            logger.error("Failed to save current pet to UserDefaults[\(keyString)] : \(error)")
            return
        }
    }
    
    public func restore() {
        logger.setMethod("restore()")
        let keyString = key.string
        do {
            logger.debug("... from UserDefaults\(keyString)")
            let data = try WhoFedBlaiseDefaults.restoreAsData(keyString)
            let parameters = try Json.decoder.decode(JsonPetParameters.self, from: data)
            logger.info("Successfully parsed")
            logger.debug("... to \(parameters)")
            hostname = parameters.hostname
            port = String(parameters.port)
            feeder = parameters.feeder
            alias = parameters.alias
            password = parameters.password
            id = parameters.id
            name = parameters.name
            race = parameters.race
            type = parameters.type
            canFeed = false
            account = parameters.account
            logLevel = parameters.logLevel
            recordNumber = parameters.recordNumber
            feedingNext = parameters.feedingNext
            notifyEvery = parameters.notifyEvery
            notifyBefore = parameters.notifyBefore
            
            wallpaperMagnifyBy = parameters.wallpaperMagnifyBy
            wallpaperOffsetWidth = parameters.wallpaperOffsetWidth
            wallpaperOffsetHeight = parameters.wallpaperOffsetHeight
            wallpaperImage = WhoFedBlaiseDefaults.getWallpaperImage(keyString)
            
            fontsizePetName = parameters.fontsizePetName
            fontsizePetAccount = parameters.fontsizePetAccount
            fontsizeTimestamp = parameters.fontsizeTimestamp
            fontsizeFeeder = parameters.fontsizeFeeder
            fontsizeFooter = parameters.fontsizeFeeder
            
            foregroundColor = parameters.foregroundColor
            backgroundColor = parameters.backgroundColor
            opacity = parameters.opacity
            
            for jsonFeedingRecord in parameters.feedingRecords {
                feedingRecords.append(FeedingRecord(timestamp: jsonFeedingRecord.timestamp, portion: jsonFeedingRecord.portion, feeder: jsonFeedingRecord.feeder, alias: jsonFeedingRecord.alias, name: jsonFeedingRecord.name))
            }
            
            save()
        } catch {
            logger.warn("\(error)")
        }
    }
    
    public static func isSimulator() -> Bool {
        var simulator: Bool = false
        #if targetEnvironment(simulator)
            simulator = true
        #endif
        return simulator
    }

}
