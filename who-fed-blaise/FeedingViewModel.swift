//
//  ViewModel.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 08.06.22.
//

import Foundation
import Combine
//import os
import UserNotifications
import BackgroundTasks
import SwiftUI

class SqlFeedingRecord: Decodable {
    var timestamp: Date = Date()
    var feeder: String = ""
    var alias: String = ""
    var portion: Float = 1
    func toJson() -> String {
        return "{\(Labels.TIMESTAMP): \(self.timestamp), \(Labels.PORTION): \(self.portion), \(Labels.ALIAS): \(self.alias), \(Labels.FEEDER): \(self.feeder)}"
    }
}

class SqlFeedingData: Decodable {
    //var account: String = ""
    var records: [SqlFeedingRecord] = []
    func toJson() -> String {
        //return "{\"account\": \(self.account), \"records\": [\(records[0].toJson()), ...]}"
        if records.count == 0 {
            return ""
        } else {
            return "{\"records\": [\(records[0].toJson()), ...]}"
        }
    }
}

class SqlResponse: Decodable {
    var returncode: Int = -1
    var message: String = ""
    func toJson() -> String {
        return "{\(Labels.RETURNCODE): \(self.returncode), \(Labels.MESSAGE): \(self.message)}"
    }
}

class HttpRequestBody: Encodable {
    var isProduction: Bool = !isSimulator()
    var action: String!
    var account: String!
    var petName: String!
    var feeder: String!
    var recordNumber: Int?
    var DeviceToken: String
    var logLevel: String?
    var portion: Float!
    var timestamp: String!
    
    convenience init(action: String, feedingViewModel: FeedingViewModel,timestamp: Date, portion: Float) {
        self.init(action: action,feedingViewModel: feedingViewModel, timestamp: timestamp)
        self.portion = portion
    }
    
    convenience init(action: String, feedingViewModel: FeedingViewModel,timestamp: Date) {
        self.init(action: action,feedingViewModel: feedingViewModel)
        self.timestamp = DateFormatters.mariadbDateFormatter.string(from:timestamp)
    }
    
    init(action: String, feedingViewModel: FeedingViewModel) {
        self.action = action
        self.account = feedingViewModel.getAccount()
        self.petName = feedingViewModel.getPetName()
        self.feeder = feedingViewModel.getFeeder()
        self.recordNumber = Int(feedingViewModel.recordNumber)
        self.DeviceToken = Parameters.getDeviceToken()
        self.logLevel = feedingViewModel.getLogLevel()
    }
    
    enum CodingKeys : String, CodingKey {
        case isProduction = "isproduction"
        case action
        case account
        case petName = "petname"
        case feeder
        case recordNumber = "recordnumber"
        case DeviceToken = "devicetoken"
        case logLevel = "loglevel"
        case portion
        case timestamp
    }
}


class FeedingViewModel: ObservableObject{
    
    let appname = Parameters.getAppName()
    let logger = Logger(Parameters.getLogLevel(), category: "FeedingViewModel")
    
    @Published var recordNumber: Float = Parameters.getRecordNumber()
    //private(set) var deviceToken: String = Parameters.getDeviceToken()
    private(set) var returnCode: Int?
    private(set) var errorMessage: String?
    // Next feedding in minutes
    @Published var feedingNext :Float = Float(Parameters.getFeedingNext())
    // Minutes before next feeding starting notifying
    @Published var notificationBefore :Float = Float(Parameters.getNotificationBefore())
    // Interval between each notification
    @Published var notificationEvery :Float = Float(Parameters.getNotifyEvery())
    
    
    @Published var petName: String = Parameters.getPetName()
    //var previousPetName = Parameters.getPetName()
    @Published var feedingRecords: [FeedingRecord] = []
    @Published var url: String = Parameters.getURL()
    @Published var account: String = Parameters.getAccount()
    @Published var feeder: String = Parameters.getFeeder()
    @Published var password: String = Parameters.getPassword()
    @Published var logLevel: String = Parameters.getLogLevel()
    
    @Published var customizeWallPaper: Bool = Parameters.getCustomizeWallPaper()
    @Published var wallPaperImage: Image = Parameters.getWallPaperImage()
    @Published var wallPaperUIImage: UIImage? = Parameters.getWallPaperUIImage()
    
    let decoder: JSONDecoder
    
    init() {
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
    }
    
    func getAccount() -> String? {
        return self.account
    }
    
    func setAccount(_ account: String) {
        self.account = account
        logger.debug("\(Labels.ACCOUNT) set to \(self.account)")
    }
    
    func getPetName() -> String {
        return self.petName
    }
    
    func setPetName(_ petName: String) {
        self.petName = petName
        logger.debug("\(Labels.PETNAME) set to \(self.petName)")
    }
    
    
    func getRecordsNumber() -> Int {
        return Int(recordNumber)
    }
    
    func setRecordsNumber(_ number: Int) {
        self.recordNumber = Float(number)
        logger.debug("\(Labels.RECORDNUMBER) set to \(self.recordNumber)")
    }
    
    func getUrl() -> String {
        return url
    }
    
    func setUrl(_ url: String) {
        self.url = url
    }
    
    func getFeeder() -> String {
        return feeder
    }
    
    func setFeeder(_ feeder: String) {
        self.feeder = feeder
        logger.debug("\(Labels.FEEDER) set to \(self.feeder)")
    }
    
    func getLogLevel() -> String {
        return logLevel
    }
    
    func setLogLevel(_ logLevel: String) {
        self.logLevel = logLevel
        logger.debug("\(Labels.LOGLEVEL) set to \(self.logLevel)")
    }
    
    func getFeedingRecords() -> Array<FeedingRecord> {
        return feedingRecords
    }
    
    func setFeedingRecords(_ records: Array<FeedingRecord>) {
        self.feedingRecords = records
    }
    
    func getFeedingRecord(_ index: Int) -> FeedingRecord {
        return getFeedingRecords()[index]
    }
    
    /*func getUrlBaseParameters() -> String {
     var _temp_ = Labels.PETNAME+"="+getPetName()!
     _temp_ = _temp_+"&"+Labels.ACCOUNT+"="+getAccount()!
     _temp_ = _temp_+"&"+Labels.FEEDER+"="+getFeeder()
     _temp_ = _temp_+"&"+Labels.RECORDNUMBER+"="+String(getRecordsNumber())
     _temp_ = _temp_+"&"+Labels.DEVICETOKEN+"="+Parameters.getDeviceToken()
     if ( !getLogLevel().elementsEqual(Logger.PARAMETER_DEFAULT) ) {
     _temp_ = _temp_+"&"+Labels.LOGLEVEL+"="+getLogLevel()
     }
     return _temp_
     }*/
    
    func add(_ portion: Float) {
        //let feedingRecord = SqlFeedingRecord()
        //let parameters=Labels.ACTION_ADD
        /*parameters=parameters+"?"+getUrlBaseParameters()
         parameters=parameters+"&"+Labels.PORTION+"="+String(portion)
         parameters=parameters+"&"+Labels.TIMESTAMP+"="+DateFormatters.mariadbDateFormatter.string(from:feedingRecord.timestamp)*/
        let httpRequestBody = HttpRequestBody(action: Labels.ACTION_ADD ,feedingViewModel: self,
                                              timestamp: Date(), portion: portion)
        dataTask(httpBody: httpRequestBody)
    }
    
    func del(_ feedingRecord: FeedingRecord) {
        let httpRequestBody = HttpRequestBody(action: Labels.ACTION_DEL ,feedingViewModel: self,
                                              timestamp: feedingRecord.timestamp)
        dataTask(httpBody: httpRequestBody)
    }
    
    @objc func get() {
        if petName=="" {return}
        //let url = Labels.ACTION_GET+"?"+getUrlBaseParameters()
        let httpRequestBody = HttpRequestBody(action: Labels.ACTION_GET ,feedingViewModel: self)
        dataTask(httpBody: httpRequestBody)
    }
    
    func dataTask(httpBody: HttpRequestBody?) {
        if let url = URL(string: getUrl()+"/"+Labels.APPFEEDING+"/") {
            logger.info("dataTask URL is \(url.absoluteString)")
            var urlRequest: URLRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            do {
                if (httpBody != nil) {
                    urlRequest.httpBody = try JSONEncoder().encode(httpBody)
                }
            } catch {
                logger.error("\(error)")
            }
            let urlSession = URLSession.shared.dataTask(with: urlRequest, completionHandler: completionHandler)
            urlSession.resume()
        }
    }
    
    func completionHandler(data: Data?, response: URLResponse?, error: Error?) {
        if let error = error {
            logger.error("\(error.localizedDescription)")
            dispatch([])
            return
        }
        guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
            logger.error("Returned 200...299 statsu code")
            dispatch([])
            return
        }
        if let mimeType = response.mimeType, mimeType != "application/json" {
            logger.error("mimeType is \(mimeType)")
            dispatch([])
            return
        }
        var feedingRecords: [FeedingRecord] = []
        if let data = data {
            logger.debug("data = \(data.base64EncodedString())")
            do {
                let sqlFeedingData = try decoder.decode(SqlFeedingData.self, from: data)
                logger.info("sqlFeedingData = \(sqlFeedingData.toJson())")
                
                guard let firstCloudantTimestamp = sqlFeedingData.records.first?.timestamp else {return}
                logger.debug("First SQL Feeding Data timestamp is \(firstCloudantTimestamp)")
                let firstFeedingRecordTimestamp = self.feedingRecords.first?.timestamp ?? firstCloudantTimestamp.addingTimeInterval(-1)
                logger.debug("First Feeding Records timestamp is \(firstFeedingRecordTimestamp)")
                
                //if firstCloudantTimestamp > firstFeedingRecordTimestamp {
                for sqlFeedingRecord in sqlFeedingData.records {
                    let feedingRecord = FeedingRecord(timestamp: sqlFeedingRecord.timestamp, feeder: sqlFeedingRecord.feeder, alias: sqlFeedingRecord.alias, portion: sqlFeedingRecord.portion)
                    logger.debug("feeding record is timestamp=\(feedingRecord.timestamp), feeder=\(feedingRecord.feeder), portion=\(feedingRecord.portion)")
                    feedingRecords.append(feedingRecord)
                }
                dispatch(feedingRecords)
                //}
            } catch {
                logger.error("\(error)")
                dispatch([])
            }
        }
    }
    
    func notificationHandler(data: Data?, response: URLResponse?, error: Error?) {
        if let error = error {
            logger.error("\(error.localizedDescription)")
            return
        }
        guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
            logger.error("Returned 200...299 statsu code")
            return
        }
        if let mimeType = response.mimeType, mimeType != "application/json" {
            logger.error("mimeType is \(mimeType)")
            return
        }
        //var Response: [FeedingRecord] = []
        if let data = data {
            logger.debug("data = \(data.base64EncodedString())")
            do {
                let sqlResponse = try decoder.decode(SqlResponse.self, from: data)
                logger.info("sqlResponse = \(sqlResponse.toJson())")
            } catch {
                logger.error("\(error)")
            }
        }
    }
    
    func dispatch(_ feedingRecords: [FeedingRecord]) {
        DispatchQueue.main.async {
            self.feedingRecords = feedingRecords
            self.logger.debug("Dispatched")
            self.requestNotification()
            //self.initTimer()
        }
    }
    
    func saveSetting() {
        logger.info("Save \(Labels.APPNAME) = \(self.appname)")
        Parameters.setPetName(self.petName)
        Parameters.setURL(self.url)
        Parameters.setRecordNumber(Int(recordNumber))
        Parameters.setAccount(self.account)
        Parameters.setFeeder(self.feeder)
        self.feedingNext = Float(60*Int(self.feedingNext/60))
        Parameters.setFeedingNext(Int(self.feedingNext))
        self.notificationBefore = Float(Int(self.notificationBefore))
        Parameters.setNotificationBefore(Int(self.notificationBefore))
        self.notificationEvery = Float(Int(self.notificationEvery))
        Parameters.setNotifyEvery(Int(self.notificationEvery))
        Parameters.setAppName(appname)
        Parameters.setLogLevel(logLevel)
    }
    
    func requestNotification() {
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        logger.debug("Existing notifications cancelled")
        
        if feedingRecords.isEmpty {
            return
        }
        
        let feedingNextInSeconds :TimeInterval = Double(feedingNext)*60 // Time interval in second
        logger.debug("Next feeding : \(feedingNext) minutes")
        let feedingStart :Date = (feedingRecords.first?.timestamp.addingTimeInterval(feedingNextInSeconds))!
        logger.info("Next feeding at \(DateFormatters.anyDateFormatter.string(from: feedingStart))")
        let content = UNMutableNotificationContent()
        content.title = "Ne m'oublie pas à \(DateFormatters.HHmmFormatter.string(from: feedingStart))"
        content.subtitle = "... et aussi mettre who-fed-blaise à jour"
        content.sound = UNNotificationSound.default
        
        var before = notificationBefore
        while before > 0 {
            let timeInterval :TimeInterval = Double(Int(feedingNext)-Int(before))*60 // Time interval in second
            let notificationStart :Date = (feedingRecords.first?.timestamp.addingTimeInterval(timeInterval))!
            logger.debug("Notification at \(DateFormatters.anyDateFormatter.string(from: notificationStart))")
            let dateComponents :DateComponents = Calendar.current.dateComponents([.hour, .minute], from: notificationStart)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
            before = before - notificationEvery
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
        setFeedingRecords(feedingRecords)
    }
    /*
    func getWallPaperPath() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let result = paths[0].appendingPathComponent(petName + ".jpg")
        logger.info("Wallpaper path: \(result)")
        return result
    }
    
    func getWallPaperUIImage() -> UIImage? {
        let fileURL = getWallPaperPath()
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }
    
    func getWallPaperImage() -> Image {
        let uiImageData = getWallPaperUIImage()
        if uiImageData != nil {
            return Image(uiImage: uiImageData!)
        }
        return Image(Defaults.WALLPAPERNAME)
    }
    */
    func loadWallPaperImage() {
        guard let uiImage = wallPaperUIImage else { return }
        wallPaperImage = Image(uiImage: uiImage)
    }
}
