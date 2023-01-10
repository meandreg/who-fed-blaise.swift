//
//  ViewModel.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 08.06.22.
//

import Foundation

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

class FeedingViewModel: ObservableObject {
    
    let url: String = "https://who-fed-blaise.o27h4hea3ks.eu-de.codeengine.appdomain.cloud/"

    @Published private var feedingData: FeedingData
    
    init() {
        feedingData = FeedingData(petName: "blaise", feedingRecords: [])
        get()
    }
    
    func getPetName() -> String {
        return feedingData.petName
    }
    
    func getFeedingRecords() -> Array<FeedingRecord> {
        return feedingData.feedingRecords
    }
    
    func add(_ portion: Int) {
        let feedingRecord = CloudantFeedingRecord()
        let string = url+"add?petname="+getPetName()+"&feeder="+feedingRecord.feeder+"&timestamp="+DateFormatters.iso8601DateFormatter.string(from: feedingRecord.timestamp)+"&portion="+portion+"&"
        let url = URL(string: string)!
        let task = URLSession.shared.dataTask(with: url, completionHandler: completionHandler)
        task.resume()
    }
    
    func del(_ feedingRecord: FeedingRecord) {
        let string = url+"del?petname="+getPetName()+"&feeder="+feedingRecord.feeder+"&timestamp="+DateFormatters.iso8601DateFormatter.string(from: feedingRecord.timestamp)+"&"
        let url = URL(string: string)!
        let task = URLSession.shared.dataTask(with: url, completionHandler: completionHandler)
        task.resume()
    }
    
    func get(_ name: String) {
        let string = url+"get?petname="+getPetName()+"&"
        let url = URL(string: string)!
        let task = URLSession.shared.dataTask(with: url, completionHandler: completionHandler)
        task.resume()
    }
    
    func get() {
        get(getPetName())
    }
    
    func completionHandler( data: Data?, response: URLResponse?, error: Error?) {
        print("completionHandler")
        if let error = error {
            print ("error: \(error)")
            return
        }
        guard let response = response as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else {
            print ("server error")
            return
        }
        if let mimeType = response.mimeType,
           mimeType == "application/json",
           let data = data,
           let dataString = String(data: data, encoding: .utf8) {
            print ("got data: \(dataString)")
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                let cloudantFeedingData = try decoder.decode(CloudantFeedingData.self, from: data)
                var feedingRecords: [FeedingRecord] = []
                for cloudantFeedingRecord in cloudantFeedingData.records {
                    
                    let feedingRecord = FeedingRecord(timestamp: cloudantFeedingRecord.timestamp, feeder: cloudantFeedingRecord.feeder, portion: cloudantFeedingRecord.portion)
                    feedingRecords.append(feedingRecord)
                }
                feedingData = FeedingData(petName: cloudantFeedingData._id, feedingRecords: feedingRecords)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func setFeedingData(cloudantFeedingData: CloudantFeedingData) {
        var feedingRecords: [FeedingRecord] = []
        for cloudantFeedingRecord in cloudantFeedingData.records {
            
            let feedingRecord = FeedingRecord(timestamp: cloudantFeedingRecord.timestamp, feeder: cloudantFeedingRecord.feeder, portion: cloudantFeedingRecord.portion)
            feedingRecords.append(feedingRecord)
        }
        feedingData = FeedingData(petName: cloudantFeedingData._id, feedingRecords: feedingRecords)
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

