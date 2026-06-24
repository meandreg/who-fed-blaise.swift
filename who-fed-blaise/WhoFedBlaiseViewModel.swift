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

class WhoFedBlaiseViewModel: ObservableObject {
    
    //@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    static let portionFull:String = if #available(iOS 17, *) {"battery.100percent"} else {"rectangle.fill"}
    static let portionHalf:String = if #available(iOS 17, *) {"battery.50percent"} else {"rectangle.lefthalf.filled"}
    
    static var deviceToken: String = WhoFedBlaiseDefaults.restoreDeviceToken()
    
    init() {
        logger.setMethod("init()")
        do {
            set(try selectedPets.getCurrentPet())
            selectedPetConfig = false
            AppDelegate.shared.whoFedBlaiseViewModel = self
            self.getUpdatedPet()
        } catch {
            logger.warn("\(error)")
        }
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
    @Published var role: Int = Role.ROLE_LEVEL_DEFAULT
    
    @Published var account: String = Defaults.ACCOUNT
    @Published var name: String = Defaults.PETNAME
    @Published var type: String = Defaults.PETTYPE
    @Published var race: String = Defaults.PETRACE
    @Published var feedingRecords: [FeedingRecord] = []
    
    @Published var recordNumber: Float = Defaults.RECORDNUMBER
    @Published var feedingNext :Float = Defaults.FEEDINGNEXT
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
    @Published var logLevel: Int = Defaults.LOGLEVEL
    private let logger = Logger(category: "WhoFedBlaiseViewModel")
    private static var LOGLEVEL: Int = Defaults.LOGLEVEL
    
    var key: Key {
        return Key(self.hostname,self.port,self.id,self.feeder)
    }
    
    var shortId: String {
        return Pet.shortId(id)
    }
    
    var short: String {
        return Pet.short(account,name,id)
    }
    
    var long: String {
        return Pet.long(hostname,port,alias,account,name,id)
    }
    
    private func set(_ pet: Pet) {
        logger.setMethod("set(\(pet.short))")
        self.hostname = pet.hostname
        self.port = pet.port
        self.feeder = pet.feeder
        self.id = pet.id
        resetWallpaper()
        resetFeedingRecords()
        WhoFedBlaiseDefaults.restore(self)
        self.name = pet.name
        self.account = pet.account
        self.race = pet.race
        self.type = pet.type
        self.role = pet.role
        WhoFedBlaiseDefaults.save(self)
        getFeedingRecords()
        logger.debug(self.string)
    }
    
    public func setLogLevel(_ level: Int) {
        logger.setMethod("setLogLevel(\(level))")
        WhoFedBlaiseViewModel.LOGLEVEL = level
        self.logLevel = level
        logger.setLevel(level)
    }
    
    public func getLogLevel() -> Int {
        return self.logLevel
    }
    
    static func getLogLevel()-> Int {
        return WhoFedBlaiseViewModel.LOGLEVEL
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
            do {
                let httpRequestBody = try HttpRequestBody.HttpRequestAddFeedingRecord(self, timestamp: current, portion: portion)
                let httpBody = try Json.encoder.encode(httpRequestBody)
                dataTask(httpBody: httpBody)
            } catch {
                logger.error("\(error)")
            }
        }
    }
    
    func delFeedingRecord(feedingRecord: FeedingRecord) {
        logger.setMethod("delFeedingRecord(\(feedingRecord))")
        do {
            let httpRequestBody = try HttpRequestBody.HttpRequestDelFeedingRecord(self, timestamp: feedingRecord.timestamp)
            let httpBody = try Json.encoder.encode(httpRequestBody)
            logger.debug("HttpRequestDelFeedingRecord = \(String(data: httpBody, encoding: .utf8)!)")
            dataTask(httpBody: httpBody)
        } catch {logger.error("\(error)")}
    }
    
    //@objc func get(_ pet: Pet) {
    func getFeedingRecords() {
        logger.setMethod("getFeedingRecords()")
        do {
            let httpRequestBody = try HttpRequestBody.HttpRequestFeedingRecords(self)
            let httpBody = try Json.encoder.encode(httpRequestBody)
            dataTask(httpBody: httpBody)
            logger.debug("Get feeding records HttpBody = \(String(data: httpBody, encoding: .utf8)!)")
        } catch {logger.error("\(error)")}
    }
    
    func getFeederPets() {
        logger.setMethod("getFeederPets()")
        if feeder == Defaults.FEEDER {return}
        do {
            let httpRequestBody = try HttpRequestBody.HttpRequestFeederPets(self)
            let httpBody = try Json.encoder.encode(httpRequestBody)
            dataTask(httpBody: httpBody)
            logger.debug("Get feeder pets HttpBody = \(String(data: httpBody, encoding: .utf8)!)")
        } catch {logger.error("\(error)")}
    }

    func getUpdatedPet() {
        logger.setMethod("getUpdatedPet()")
        if feeder == Defaults.FEEDER {return}
        do {
            let httpRequestBody = try HttpRequestBody.HttpRequestUpdatedPet()
            let httpBody = try Json.encoder.encode(httpRequestBody)
            logger.info("HttpBody = \(String(data: httpBody, encoding: .utf8)!)")
            dataTask(httpBody: httpBody)
        } catch {logger.error("\(error)")}
    }

    func dataTask(httpBody: Data) {
        logger.setMethod("datatask(\(httpBody))")
        if let url = URL(string: Defaults.PROTOCOL+"://"+hostname+":"+String(port)+"/"+Labels.APPFEEDING+"/") {
            logger.debug("dataTask URL is \(url.absoluteString)")
            var urlRequest: URLRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = httpBody
            let urlSession = URLSession.shared.dataTask(with: urlRequest, completionHandler: completionHandler)
            urlSession.resume()
            logger.debug("call \(url.absoluteString) with \(String(data: httpBody, encoding: .utf8)!)")
        }
    }
    
    func completionHandler(data: Data?, response: URLResponse?, error: Error?) {
        guard checkResponse(data: data, response: response, error: error) else {return}
        decodeResponse(data: data!)
    }
    
    func checkResponse(data: Data?, response: URLResponse?, error: Error?) -> Bool {
        logger.setMethod("checkResponse(...))")
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
        logger.setMethod("decodeResponse(data))")
        logger.debug("\(String(data: data, encoding: .utf8)!)")
        do {
            let response = try Json.decoder.decode(HttpResponse.self, from: data)
            logger.debug("httpResponse.returncode: \(response.returncode), httpResponse.message: \(response.message ?? "")")
            guard response.returncode==0 else {
                logger.error("return code is not 0 : \(response)")
                return
            }
            
            guard let data = response.data else {
                logger.error("data object does not exists : \(response)")
                return
            }
            
            switch data.action {
            case Labels.ACTION_GETUPDATEDPET:
                let id = try response.getUpdatedPetId()
                dispatchUpdatedPet(id)
            case Labels.ACTION_GETFEEDERPETS:
                let feederPets = try response.getFeederPets(hostname: self.hostname, port: self.port)
                dispatchFeederPets(feederPets)
            case Labels.ACTION_GETFEEDINGRECORDS, Labels.ACTION_ADDFEEDINGRECORD, Labels.ACTION_DELFEEDINGRECORD:
                let pet = try response.getFeedingRecords(hostname: self.hostname, port: self.port)
                dispatchPetFeedingRecords(pet)
            default:
                logger.error("Invalid action: \(data.action)")
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
        logger.setMethod("dispatch()")
        DispatchQueue.main.async {
            self.logger.error("Failed to return data from remote server")
            self.enableFeeding()
        }
    }
    
    func dispatchFeederPets(_ feederPets: PetArray) {
        logger.setMethod("dispatchFeederPets(...)")
        DispatchQueue.main.async {
            self.feederPets.removeAll()
            if feederPets.isEmpty {
                self.logger.warn("FeederPets list is empty")
                return
            }
            for pet in feederPets.pets {
                do {
                    try self.feederPets.append(pet)
                } catch {
                    self.logger.error("Failed to add \(pet.short) to \(self.feederPets.name); \(error)")
                }
                if self.id == pet.id {
                    self.swapTo(pet.id)
                }
            }
            do {
                self.logger.info("Re-initiliazed Pet list \(self.feederPets.name)")
                self.logger.debug("Re-initiliazed Pet list \(self.feederPets.name) : \(try self.feederPets.string())")
            } catch {
                self.logger.error("Failed to stringify pet list \(self.feederPets.name); \(error)")
            }
            if self.selectedPets.isEmpty {
                self.addFeederPet()
            }
        }
    }

    
    func dispatchPetFeedingRecords(_ pet: Pet) {
        logger.setMethod("dispatchFeedingRecords(...Pet...)")
        DispatchQueue.main.async {
            self.feedingEnabled = true
            self.id = pet.id
            self.name = pet.name
            self.account = pet.account
            self.feeder = pet.feeder
            self.alias = pet.alias
            self.role = pet.role
            self.account = pet.account
            self.type = pet.type
            self.race = pet.race
            self.name = pet.name
            self.feedingRecords = pet.feedingRecords
            self.logger.info("... of \(self.short)")
            self.logger.debug("... \(self.string)")
        }
    }
    
    func dispatchUpdatedPet(_ id: UUID) {
        logger.setMethod("dispatchUpdatedPet(\(Pet.shortId(id)))")
        DispatchQueue.main.async {
            self.switchTo(id)
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
        WhoFedBlaiseDefaults.save(self)
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
            return try Json.toString(encodable: try JsonPetParameters(self))
        } catch {
            let message = String("\(error)")
            logger.error(message)
            return String(message)
        }
    }
}
