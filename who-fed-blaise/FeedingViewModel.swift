//
//  ViewModel.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 08.06.22.
//

import Foundation
import Combine

class CloudantFeedingRecord: Decodable {
    var timestamp: Date = Date()
    var feeder: String = ProcessInfo.processInfo.hostName
    var portion: Int = 1
}

class CloudantFeedingData: Decodable {
    var _id: String = "blaise"
    var _rev: String?
    var records: [CloudantFeedingRecord] = []
}

class FeedingViewModel: ObservableObject{
    
    let PARAM_PETNAME="petname"
    let PARAM_FEEDER="feeder"
    let PARAM_PORTION="portion"
    let PARAM_TIMESTAMP="timestamp"
    let PARAM_RECORDNUMBER="recordnumber"

    @Published var feedingData: FeedingModel
    @Published var urlSession: FeedingURLSession
    
    var  cancellable = Set<AnyCancellable>()
    
    var buffer: FeedingModel
    
    let decoder: JSONDecoder
    
    init() {
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        feedingData = FeedingModel()
        urlSession = FeedingURLSession()
        buffer = FeedingModel()
        get()
    }
    
    func getPetName() -> String {
        return feedingData.petName
    }
    
    func setPetName(_ name: String) {
        feedingData.petName = name
    }
    
    func getRecordsNumber() -> Int {
        return urlSession.recordNumber
    }
    
    func setRecordsNumber(_ number: Int) {
        urlSession.recordNumber = number
    }
    
    func getUrl() -> String {
        return urlSession.url
    }
    
    func setUrl(_ url: String) {
        urlSession.url = url
    }
    
    func getFeedingRecords() -> Array<FeedingRecord> {
        return feedingData.feedingRecords
    }
    
    func setFeedingRecords(_ records: Array<FeedingRecord>) {
        Logger.info("SET FEEDINGRECORD = ",records)
        feedingData.feedingRecords = records
    }
    
    func getUrlBaseParameters() -> String {
        return "\(PARAM_PETNAME)=\(getPetName())&\(PARAM_RECORDNUMBER)=\(String(urlSession.recordNumber))"
    }
    
    func add(_ portion: Int) {
        let feedingRecord = CloudantFeedingRecord()
        let parameters = "add?\(getUrlBaseParameters())&\(PARAM_FEEDER)=\(feedingRecord.feeder)&\(PARAM_PORTION)=\(String(feedingRecord.portion))&\(PARAM_TIMESTAMP)=\(DateFormatters.iso8601DateFormatter.string(from:feedingRecord.timestamp))"
        dataTask(parameters)
    }
    
    func del(_ feedingRecord: FeedingRecord) {
        let parameters = "del?\(getUrlBaseParameters())&\(PARAM_TIMESTAMP)=\(DateFormatters.iso8601DateFormatter.string(from: feedingRecord.timestamp))&\(PARAM_PORTION)=\(String(feedingRecord.portion))&\(PARAM_PORTION)=\(String(feedingRecord.feeder))"
        dataTask(parameters)
    }
    
    func get(_ name: String) {
        feedingData.petName=name
        dataTask("get?\(getUrlBaseParameters())")
    }
    
    func get() {
        get(getPetName())
    }
    
    func dataTask(_ parameters: String) {
        let url: URL = URL(string: getUrl()+parameters)!
        Logger.info("URL is ",url.absoluteString)
        let urlSession = URLSession.shared.dataTask(with: url, completionHandler: completionHandler)
        urlSession.resume()
    }

/*    func dataTask(_ parameters: String) {
        let url: URL = URL(string: getUrl()+parameters)!
        Logger.info("URL is ",url.absoluteString)
        let session = URLSession.shared
        // Fetch the combine way
        session.dataTaskPublisher(for: url)
        // tryMap offers a way to process the response with a closure that can throw an error
            .tryMap { element -> Data in
                Logger.info("Start",component: "tryMap")
                guard let response = element.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                Logger.info("End",component: "tryMap")
                return element.data
            }
        // decode the response from tryMap into a custom data structure
            .decode(type: CloudantFeedingData.self, decoder: decoder)
        // type erase the publisher so that its easy to handle the response in the sink subscriber
            .eraseToAnyPublisher()
        // convenience subscriber built into combine
            .sink(
                //. completion when the publisher completes with failure or no error
                receiveCompletion: { status in
                    Logger.info("Start",component: "receiveCompletion")
                    switch status {
                    case .finished:
                        print("Completed")
                        break
                    case .failure(let error):
                        print("Receiver error \(error)")
                        break
                    }
                    Logger.info("end",component: "receiveCompletion")
                },
                // receive the data
                receiveValue: { data in
                    Logger.info("Start",component: "receiveValue")
                    Logger.info("cloudantFeedingData = ",data._id)
                    var feedingRecords: [FeedingRecord] = []
                    for cloudantFeedingRecord in data.records {
                        Logger.info(cloudantFeedingRecord.timestamp)
                        let feedingRecord = FeedingRecord(timestamp: cloudantFeedingRecord.timestamp, feeder: cloudantFeedingRecord.feeder, portion: cloudantFeedingRecord.portion)
                        Logger.info(feedingRecord)
                        feedingRecords.append(feedingRecord)
                    }
                    DispatchQueue.main.async {
                        self.data.feedingRecords = feedingRecords
                    }
                    print("Data received \(data)")
                    Logger.info("End",component: "receiveValue")
                    
                }
            )
            .store(in: &cancellable)
    }*/
    
    func completionHandler(data: Data?, response: URLResponse?, error: Error?) {
        Logger.component = "completionHandler"
    
        Logger.info("Start")
       
        if let error = error {
            Logger.error(error)
            return
        }
        guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
            Logger.error("(200...299).contains(response.statusCode)")
            return
        }
        if let mimeType = response.mimeType, mimeType != "application/json" {
            Logger.error("mimeType is ",mimeType)
            return
        }
        var feedingRecords: [FeedingRecord] = []
        if let data = data {
            Logger.info("data = ", data.base64EncodedString())
            do {
                let cloudantFeedingData = try decoder.decode(CloudantFeedingData.self, from: data)
                Logger.info("cloudantFeedingData = ",cloudantFeedingData._id)
                //var feedingRecords: [FeedingRecord] = []
                for cloudantFeedingRecord in cloudantFeedingData.records {
                    Logger.info(cloudantFeedingRecord.timestamp)
                    let feedingRecord = FeedingRecord(timestamp: cloudantFeedingRecord.timestamp, feeder: cloudantFeedingRecord.feeder, portion: cloudantFeedingRecord.portion)
                    Logger.info(feedingRecord)
                    feedingRecords.append(feedingRecord)
                }
                DispatchQueue.main.async {
                    self.feedingData.feedingRecords = feedingRecords
                }
            } catch {
                Logger.error(error)
            }
        }
    }
    
    func setFeedingData(cloudantFeedingData: CloudantFeedingData) {
        var feedingRecords: [FeedingRecord] = []
        for cloudantFeedingRecord in cloudantFeedingData.records {
            
            let feedingRecord = FeedingRecord(timestamp: cloudantFeedingRecord.timestamp, feeder: cloudantFeedingRecord.feeder, portion: cloudantFeedingRecord.portion)
            feedingRecords.append(feedingRecord)
        }
        //feedingData = FeedingData(petName: cloudantFeedingData._id, feedingRecords: feedingRecords)
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
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        return dateFormatter
    }
    static var logDateFormatter: DateFormatter  {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm:ss.SSS"
        return dateFormatter
    }
    
    init() {
    }
}

final class Logger {
    static var component: String?
    static var separator: String = "]["
    
    static func log(_ items: Any..., level: String, component: String = "") {
        var message: String = ""
        for item in items {
            message=message+"\(item)"
        }
        
        /*if component == "" {
            print(level,message,separator: separator)
        } else {
            print(level,component,message,separator: separator)
        }*/
        print(level,items)
    }
    
    static func error(_ items: Any..., component: String!) {
        log(items, level: "ERROR", component: component)
    }
    
    static func warning(_ items: Any..., component: String!) {
        log(items, level: "WARNING", component: component)
    }
    
    static func info(_ items: Any..., component: String!) {
        log(items, level: "INFO", component: component)
    }
    
    static func error(_ items: Any...) {
        log(items, level: "ERROR")
    }
    
    static func warning(_ items: Any...) {
        log(items, level: "WARNING")
    }
    
    static func info(_ items: Any...) {
        log(items, level: "INFO")
    }
}

