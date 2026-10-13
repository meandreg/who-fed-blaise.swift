//
//  Logger.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 07.10.24.
//

import Foundation
import os

enum LoggerErrors: Error {
    case InvalidLevel(String)
}

class Logger {
    static let LEVEL_FATAL="fatal"
    static let LEVEL_ERROR="error"
    static let LEVEL_WARNING="warning"
    static let LEVEL_INFO="info"
    static let LEVEL_DEBUG="debug"
    static let LEVEL_ALL="silly"
    
    private static let INDEX_FATAL=0
    private static let INDEX_ERROR=1
    private static let INDEX_WARNING=2
    private static let INDEX_INFO=3
    private static let INDEX_DEBUG=4
    private static let INDEX_ALL=5
    
    static let LEVELS = [Logger.LEVEL_FATAL,Logger.LEVEL_ERROR,Logger.LEVEL_WARNING,Logger.LEVEL_INFO,Logger.LEVEL_DEBUG,Logger.LEVEL_ALL]
    
    private static let SUBSYTEM:String = "WFB"
    private static let CATEGORY:String = "Logger"
    private static var LEVEL: Int = LEVELS.firstIndex(of: Defaults.LOGLEVEL) ?? Logger.INDEX_ERROR
    private static let LOGGER:os.Logger = os.Logger(subsystem: Logger.SUBSYTEM, category: Logger.CATEGORY)
    
    static func setLevel(_ level: String) {
        do {
            Logger.LEVEL = try Logger.level(level)
        } catch {
            LOGGER.error("Failed to set Logger.LEVEL : \(error)")
        }
    }

    private static func level(_ level: String) throws -> Int {
        guard let index = Logger.LEVELS.firstIndex(of: level) else {
            throw LoggerErrors.InvalidLevel(level)
        }
        return index
    }

    private var logger: os.Logger
    private var level: Int = LEVELS.firstIndex(of: Defaults.LOGLEVEL) ?? Logger.LEVEL
    private var subsystem:String = "wfb"
    private var category:String
    private var method:String?
        
    init(category:String, level:String = Defaults.LOGLEVEL) {
        self.category = category
        self.logger = os.Logger(subsystem: Logger.SUBSYTEM, category: category)
        setLevel(level)
    }
    
    func setLevel(_ level: String) {
        do {
            self.level = try Logger.level(level)
        } catch {
            logger.error("Failed to set logger level : \(error)")
        }
    }
    
    func setMethod(_ method: String) {
        self.method = method
        self.debug("Start")
    }
    
    private func format(_ message: String, level: String) -> String {
        let timestamp = DateFormatters.iso8601DateFormatter.string(from: Date())
        var context=self.subsystem+"."+self.category
        if let method = self.method {
            if method.starts(with: "(") {
                context.append(method)
            } else {
                context.append("."+method)
            }
        }
        return "\(timestamp) \(level) \(context) \(message)"
    }
    
    func info(_ message: String) {
        if (level>=Logger.INDEX_INFO) {
            logger.info("\(self.format(message, level: Logger.LEVEL_INFO))")
        }
    }

    func warn(_ message:String) {
        if (level>=Logger.INDEX_WARNING) {
            logger.warning("\(self.format(message, level: Logger.LEVEL_WARNING))")
        }
    }

    func error(_ message:String) {
        if (level>=Logger.INDEX_ERROR) {
            logger.error("\(self.format(message, level: Logger.LEVEL_ERROR))")
        }
    }

    func debug(_ message:String) {
        if (level>=Logger.INDEX_DEBUG) {
            logger.debug("\(self.format(message, level: Logger.LEVEL_DEBUG))")
        }
    }

}
