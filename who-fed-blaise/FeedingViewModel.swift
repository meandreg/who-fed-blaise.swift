//
//  ViewModel.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 08.06.22.
//

import Foundation
import Combine
import os
import UserNotifications
import BackgroundTasks

class CloudantFeedingRecord: Decodable {
    var timestamp: Date = Date()
    var feeder: String = ""
    var portion: Float = 1
}

class CloudantFeedingData: Decodable {
    var _id: String?
    var _rev: String?
    var records: [CloudantFeedingRecord] = []
}

class FeedingViewModel: ObservableObject{
    
    let PARAM_APPNAME="appname"
    let PARAM_URL="url"
    
    let ACTION_GET="get"
    let ACTION_ADD="add"
    let ACTION_DEL="del"
    let ACTION_SUB="sub"
    let ACTION_UNS="uns"
    
    let PARAM_PETNAME="petname"
    let PARAM_FEEDER="feeder"
    let PARAM_PORTION="portion"
    let PARAM_TIMESTAMP="timestamp"
    let PARAM_RECORDNUMBER="recordnumber"
    let PARAM_DEVICETOKEN="devicetoken"
    
    let PARAM_FEEDINGNEXT="feedingnext"
    let PARAM_NOTIFBEFORE="notifbefore"
    let PARAM_NOTIFEVERY="notifevery"

    let appname = "who-fed-blaise"
    let logger = Logger(subsystem: "who-fed-blaise", category: "FeedingViewModel")
    let userDefault = UserDefaults.standard
    /*let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
        print("Timer fired!")
    }*/
    @Published var recordNumber: Float = 3
    private (set) var deviceToken: String 
    private (set) var returnCode: Int?
    private (set) var errorMessage: String?
    // Next feedding in minutes
    @Published var feedingNext :Float = 60*12
    // Minutes before next feeding starting notifying
    @Published var notificationBefore :Float = 60
    // Interval between each notification
    @Published var notificationEvery :Float = 10
    
    @Published var timerLongEvery :Float = 10
    @Published var timerShortEvery :Float = 1
    
    @Published var petName: String = "blaise"
    @Published var feedingRecords: [FeedingRecord] = []
    @Published var url: String = "https://who-fed-blaise.o27h4hea3ks.eu-de.codeengine.appdomain.cloud/"
    //@Published var url: String = "http://localhost:8080/"
    @Published var feeder: String = ProcessInfo.processInfo.hostName
    
    
    let decoder: JSONDecoder
    
    init() {
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let appname = userDefault.string(forKey: PARAM_APPNAME)
        if appname != nil {
            getSetting()
        } else {
            saveSetting()
        }
        
        //get()
    }
    
    func getPetName() -> String? {
            return self.petName
    }
    
    func setPetName(_ petName: String) {
        self.petName = petName
        logger.debug("petName set to \(self.petName)")
    }
    
    
    func getRecordsNumber() -> Int {
        return Int(recordNumber)
    }
    
    func setRecordsNumber(_ number: Int) {
        self.recordNumber = Float(number)
        logger.debug("recordNumber set to \(self.recordNumber)")
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
        logger.debug("feeder set to \(self.feeder)")
    }
    
    func getFeedingRecords() -> Array<FeedingRecord> {
        return feedingRecords
    }
    
    func setFeedingRecords(_ records: Array<FeedingRecord>) {
        self.feedingRecords = records
    }
    
    func getDeviceToken() -> String {
        return deviceToken
    }
    
    func setDeviceToken(_ deviceToken: String) {
        self.deviceToken = deviceToken
    }
    
    func getUrlBaseParameters() -> String {
        return "\(PARAM_PETNAME)=\(String(describing: petName.lowercased()))&\(PARAM_RECORDNUMBER)=\(String(getRecordsNumber()))"
    }
    
    func add(_ portion: Float) {
        let feedingRecord = CloudantFeedingRecord()
        let parameters = "\(ACTION_ADD)?\(getUrlBaseParameters())&\(PARAM_FEEDER)=\(getFeeder())&\(PARAM_PORTION)=\(String(portion))&\(PARAM_TIMESTAMP)=\(DateFormatters.iso8601DateFormatter.string(from:feedingRecord.timestamp))"
        dataTask(parameters)
    }
    
    func del(_ feedingRecord: FeedingRecord) {
        let parameters = "\(ACTION_DEL)?\(getUrlBaseParameters())&\(PARAM_TIMESTAMP)=\(DateFormatters.iso8601DateFormatter.string(from: feedingRecord.timestamp))&\(PARAM_PORTION)=\(String(feedingRecord.portion))&\(PARAM_PORTION)=\(String(feedingRecord.feeder))"
        dataTask(parameters)
    }
    
    func sub() {
        let parameters = "\(ACTION_SUB)?\(getUrlBaseParameters())&\(PARAM_DEVICETOKEN)=\(getFeeder())"
        dataTask(parameters)
    }
    
    func unsub() {
        let parameters = "\(ACTION_UNS)?\(getUrlBaseParameters())&\(PARAM_DEVICETOKEN)=\(getFeeder())"
        dataTask(parameters)
    }
    

    @objc func get() {
        dataTask("\(ACTION_GET)?\(getUrlBaseParameters())")
    }
 
    func dataTask(_ parameters: String) {
        let url: URL = URL(string: getUrl()+parameters)!
        logger.info("dataTask URL is \(url.absoluteString)")
        let urlSession = URLSession.shared.dataTask(with: url, completionHandler: completionHandler)
        urlSession.resume()
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
                let cloudantFeedingData = try decoder.decode(CloudantFeedingData.self, from: data)
                logger.debug("cloudantFeedingData = \(cloudantFeedingData._id ?? "nil")")
                
                guard let firstCloudantTimestamp = cloudantFeedingData.records.first?.timestamp else {return}
                logger.debug("First Cloudant Feeding Data timestamp is \(firstCloudantTimestamp)")
                let firstFeedingRecordTimestamp = self.feedingRecords.first?.timestamp ?? firstCloudantTimestamp.addingTimeInterval(-1)
                logger.debug("First Feeding Records timestamp is \(firstFeedingRecordTimestamp)")
                
                //if firstCloudantTimestamp > firstFeedingRecordTimestamp {
                    for cloudantFeedingRecord in cloudantFeedingData.records {
                        let feedingRecord = FeedingRecord(timestamp: cloudantFeedingRecord.timestamp, feeder: cloudantFeedingRecord.feeder, portion: cloudantFeedingRecord.portion)
                        logger.info("feeding record is timestamp=\(feedingRecord.timestamp), feeder=\(feedingRecord.feeder), portion=\(feedingRecord.portion)")
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
    
    func dispatch(_ feedingRecords: [FeedingRecord]) {
        DispatchQueue.main.async {
            self.feedingRecords = feedingRecords
            self.logger.debug("Dispatched")
            self.requestNotification()
            //self.initTimer()
        }
    }
    
    func getSetting() {
        petName = userDefault.string(forKey: PARAM_PETNAME)!
        logger.info("petName = \(self.petName)")
        url = userDefault.string(forKey: PARAM_URL)!
        logger.info("url = \(self.url)")
        recordNumber = userDefault.float(forKey: PARAM_RECORDNUMBER)
        logger.info("record number = \(self.recordNumber)")
        feeder = userDefault.string(forKey: PARAM_FEEDER)!
        logger.info("feeder = \(self.feeder)")
        
        feedingNext = userDefault.float(forKey: PARAM_FEEDINGNEXT)
        logger.info("feedingNext = \(self.feedingNext)")
        notificationBefore = userDefault.float(forKey: PARAM_NOTIFBEFORE)
        logger.info("notificationBefore = \(self.notificationBefore)")
        notificationEvery = userDefault.float(forKey: PARAM_NOTIFEVERY)
        logger.info("notificationEvery = \(self.notificationEvery)")
    }
    
    func saveSetting() {
        logger.info("Save \(self.PARAM_PETNAME) = \(self.petName)")
        userDefault.set(petName, forKey: PARAM_PETNAME)
        logger.info("Save \(self.PARAM_FEEDER) = \(self.feeder)")
        userDefault.set(feeder, forKey: PARAM_FEEDER)
        logger.info("Save \(self.PARAM_RECORDNUMBER) = \(self.recordNumber)")
        userDefault.set(recordNumber, forKey: PARAM_RECORDNUMBER)
        logger.info("Save \(self.PARAM_URL) = \(self.url)")
        userDefault.set(url, forKey: PARAM_URL)

        logger.info("Save \(self.PARAM_FEEDINGNEXT) = \(self.feedingNext)")
        userDefault.set(feedingNext, forKey: PARAM_FEEDINGNEXT)
        logger.info("Save \(self.PARAM_NOTIFBEFORE) = \(self.notificationBefore)")
        userDefault.set(notificationBefore, forKey: PARAM_NOTIFBEFORE)
        logger.info("Save \(self.PARAM_NOTIFEVERY) = \(self.notificationEvery)")
        userDefault.set(notificationEvery, forKey: PARAM_NOTIFEVERY)
 
        logger.info("Save \(self.PARAM_APPNAME) = \(self.appname)")
        userDefault.set(appname, forKey: PARAM_APPNAME)
    }
    
    func requestNotification() {
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        logger.debug("Existing notifications cancelled")
        
        if feedingRecords.isEmpty {
            return
        }
        
        let timeInterval :TimeInterval = Double(feedingNext)*60 // Time interval in second
        let feedingStart :Date = (feedingRecords.first?.timestamp.addingTimeInterval(timeInterval))!
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
    
    /*func initTimer() {
        let timeInterval :TimeInterval = Double(timerShortEvery)*60 // Time interval in second
        let timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(get), userInfo: nil, repeats: true)
    }*/
    
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

    func setFeedingData(cloudantFeedingData: CloudantFeedingData) {
        var feedingRecords: [FeedingRecord] = []
        for cloudantFeedingRecord in cloudantFeedingData.records {
            
            let feedingRecord = FeedingRecord(timestamp: cloudantFeedingRecord.timestamp, feeder: cloudantFeedingRecord.feeder, portion: cloudantFeedingRecord.portion)
            feedingRecords.append(feedingRecord)
        }
        setFeedingRecords(feedingRecords)
    }
}

final class DateFormatters {
    
    static let heightHours: TimeInterval = -TimeInterval(8*60*60)
    static let oneDay: TimeInterval = 3*heightHours
    static let twoDay: TimeInterval = 2*oneDay
    static let oneWeek: TimeInterval = 7*oneDay
    static let oneMonth: TimeInterval = 31*oneDay
    static let twoMonth: TimeInterval = 2*oneMonth
    
    static var recordNumber = 3
    
    static var iso8601DateFormatter: ISO8601DateFormatter {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter
   }
    
    static var todayFormatter:DateFormatter {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "'TODAY 'HH:mm"
        return dateFormatter
    }
    static var yesterdayFormatter: DateFormatter {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "'YESTERDAY 'HH:mm"
        return dateFormatter
    }
    static var thisWeekFormatter: DateFormatter  {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "EEEE HH:mm"
        return dateFormatter
    }
    static var thisMonthFormatter: DateFormatter  {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "MMMM dd HH:mm"
        return dateFormatter
    }
    static var anyDateFormatter: DateFormatter  {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "EEEE yyyy.MM.dd HH:mm"
        return dateFormatter
    }
    static var logDateFormatter: DateFormatter  {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm:ss.SSS"
        return dateFormatter
    }
    static var HHmmFormatter: DateFormatter  {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
    }
    
    init() {
    }
}

