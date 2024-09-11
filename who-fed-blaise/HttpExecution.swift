//
//  HttpExecution.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 05.07.24.
//

import Foundation
import os

class HttpExecution {
    
    static let logger = Logger(subsystem: "who-fed-blaise", category: "HttpExecution")
    static let decoder: JSONDecoder = JSONDecoder()
    
    static func dataTask(_ action: String, _ parameters: String, ) {
        let url: URL = URL(string: url+parameters)!
        logger.info("dataTask URL is \(url.absoluteString)")
        let urlSession = URLSession.shared.dataTask(with: url, completionHandler: completionHandler)
        urlSession.resume()
    }
    
    static func completionHandler(data: Data?, response: URLResponse?, error: Error?) {
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
 
}
