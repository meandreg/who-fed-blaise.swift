//
//  Logger.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 07.10.24.
//

import Foundation
import os

class Logger {
    static let PARAMETER_LOGLEVEL="loglevel"
    static let PARAMETER_DEFAULT="default"
    static let PARAMETER_ERROR="error"
    static let PARAMETER_WARNING="warning"
    static let PARAMETER_INFO="info"
    static let PARAMETER_DEBUG="debug"
    static let PARAMETER_ALL="silly"
    
    static let LEVELS = [Logger.PARAMETER_ERROR,Logger.PARAMETER_WARNING,Logger.PARAMETER_INFO,Logger.PARAMETER_DEBUG,Logger.PARAMETER_ALL]
    static let LEVEL_DEFAULT:Int=Logger.LEVELS.firstIndex(of: Logger.PARAMETER_ERROR) ?? -1
    static let LEVEL_ERROR:Int=Logger.LEVELS.firstIndex(of: Logger.PARAMETER_ERROR) ?? -1
    static let LEVEL_WARNING:Int=Logger.LEVELS.firstIndex(of: Logger.PARAMETER_WARNING) ?? -1
    static let LEVEL_INFO:Int=Logger.LEVELS.firstIndex(of: Logger.PARAMETER_INFO) ?? -1
    static let LEVEL_DEBUG:Int=Logger.LEVELS.firstIndex(of: Logger.PARAMETER_DEBUG) ?? -1
    static let LEVEL_ALL:Int=Logger.LEVELS.firstIndex(of: Logger.PARAMETER_ALL) ?? -1

    var logger:os.Logger
    var subsystem:String = "WFB"
    var category:String
    var level:Int = Logger.LEVEL_ERROR
    
    init(_ level:String, category:String) {
        self.category = category
        logger = os.Logger(subsystem: self.subsystem, category: self.category)
        self.setLevel(level)
    }

    func setLevel(_ level:String) {
        let index:Int = Logger.LEVELS.firstIndex(of: level) ?? self.level
        if index != -1 {
            self.level = index
        }
    }

    func format(_ message: String,_ level: Int) -> String {
        let timestamp = DateFormatters.iso8601DateFormatter.string(from: Date())
        return "\(timestamp) \(Logger.LEVELS[level]) \(self.subsystem).\(self.category) \(message)"
    }
    
    func log(_ message:String, _ level:Int) {
        let message = format(message,level)
        switch(level) {
        case Logger.LEVEL_ERROR:
            self.logger.error("\(message)")
            break
        case Logger.LEVEL_WARNING:
            self.logger.warning("\(message)")
            break
        case Logger.LEVEL_INFO:
            self.logger.info("\(message)")
            break
        case Logger.LEVEL_DEBUG, Logger.LEVEL_ALL:
            self.logger.debug("\(message)")
            break
        default:
            break
        }
    }

    func info(_ message:String) {
        if self.level>=Logger.LEVEL_INFO {self.log(message,Logger.LEVEL_INFO) }
    }

    func warn(_ message:String) {
        if self.level>=Logger.LEVEL_WARNING { self.log(message,Logger.LEVEL_WARNING) }
    }

    func error(_ message:String) {
        if self.level>=Logger.LEVEL_ERROR { self.log(message,Logger.LEVEL_WARNING) }
    }

    func debug(_ message:String) {
        if self.level>=Logger.LEVEL_DEBUG { self.log(message,Logger.LEVEL_DEBUG) }
    }

}
