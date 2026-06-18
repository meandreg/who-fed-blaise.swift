//
//  Logger.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 07.10.24.
//

import Foundation
import os

class Logger {
    static let LABEL_NONE="none"
    static let LABEL_ERROR="error"
    static let LABEL_WARNING="warning"
    static let LABEL_INFO="info"
    static let LABEL_DEBUG="debug"
    static let LABEL_ALL="silly"
    static let LABEL_DEFAULT="Default"
    
    static let LEVEL_DEFAULT: Int = -1
    static let LEVEL_NONE=0
    static let LEVEL_ERROR=10
    static let LEVEL_WARNING=20
    static let LEVEL_INFO=50
    static let LEVEL_DEBUG=100
    static let LEVEL_ALL=1000
    
    static let LABELS = [Logger.LABEL_DEFAULT,Logger.LABEL_NONE,Logger.LABEL_ERROR,Logger.LABEL_WARNING,Logger.LABEL_INFO,Logger.LABEL_DEBUG,Logger.LABEL_ALL]
    static let LEVELS = [Logger.LEVEL_DEFAULT,Logger.LEVEL_NONE,Logger.LEVEL_ERROR,Logger.LEVEL_WARNING,Logger.LEVEL_INFO,Logger.LEVEL_DEBUG,Logger.LEVEL_ALL]
    
    static let SUBSYTEM:String = "WFB"
    static let CATEGORY:String = "Logger"
    private static let LEVEL = Logger.LEVEL_ERROR
    private static let LOGGER:os.Logger = os.Logger(subsystem: Logger.SUBSYTEM, category: Logger.CATEGORY)
    
    static private func newLogger(category: String) -> os.Logger {
        return os.Logger(subsystem: Logger.SUBSYTEM, category: category)
    }
    
    static func getLevel(_ label: String) -> Int {
        guard let index = Logger.LABELS.firstIndex(of: label) else {
            Logger.LOGGER.error("Invalid log label: \(label)")
            return Logger.LEVEL_DEFAULT
        }
        return Logger.LEVELS[index]
    }
    
    static func getLabel(_ level: Int) -> String {
        guard let index = Logger.LEVELS.firstIndex(of: level) else {
            Logger.LOGGER.error("Invalid log level: \(level)")
            return Logger.LABEL_DEFAULT
        }
        return Logger.LABELS[index]
    }
    
    var logger:os.Logger
    
    var subsystem:String = "wfb"
    var category:String
    var method:String?
    var level:Int = Logger.LEVEL_DEFAULT
    
    init(category:String, level:Int=Logger.LEVEL_DEFAULT) {
        self.category = category
        self.level = level
        self.logger = Logger.newLogger(category: self.category)
    }

    func setLevel(_ label: String) {
        guard let index = Logger.LABELS.firstIndex(of: label) else {
            Logger.LOGGER.error("Invalid log label: \(label)")
            return
        }
        self.level = Logger.LEVELS[index]
    }

    func setLevel(_ level: Int) {
        guard let index = Logger.LEVELS.firstIndex(of: level) else {
            Logger.LOGGER.error("Invalid log level: \(level)")
            return
        }
        self.level = Logger.LEVELS[index]
    }

    func getLabel() -> String {
        return Logger.getLabel(level)
    }

    func setMethod(_ method: String) {
        self.method = method
        self.debug("Start")
    }
    
    func format(_ message: String,_ label: String) -> String {
        let timestamp = DateFormatters.iso8601DateFormatter.string(from: Date())
        var context=self.subsystem+"."+self.category
        if let method = self.method {
            if method.starts(with: "(") {
                context.append(method)
            } else {
                context.append("."+method)
            }
        }
        return "\(timestamp) \(label) \(context) \(message)"
    }
    
    func log(_ message:String, _ level:Int) {
        switch(level) {
        case Logger.LEVEL_ERROR:
            self.logger.error("\(self.format(message,Logger.LABEL_ERROR))")
            break
        case Logger.LEVEL_WARNING:
            self.logger.warning("\(self.format(message,Logger.LABEL_WARNING))")
            break
        case Logger.LEVEL_INFO:
            self.logger.info("\(self.format(message,Logger.LABEL_INFO))")
            break
        case Logger.LEVEL_DEBUG, Logger.LEVEL_ALL:
            self.logger.debug("\(self.format(message,Logger.LABEL_DEBUG))")
            break
        default:
            break
        }
    }

    func info(_ message:String) {
        //print("\(Logger.LABEL_INFO) : \(message)")
        //Logger.LOGGER.debug("\(Logger.LABEL_INFO) : \(message)")
        var level=self.level
        if self.level==Logger.LEVEL_DEFAULT { level=WhoFedBlaiseViewModel.getLogLevel() }
        //logger.debug("\(Logger.LABEL_DEBUG) (\(level)) : \(message)")
        if level>=Logger.LEVEL_INFO {self.log(message,Logger.LEVEL_INFO ) }
    }

    func warn(_ message:String) {
        //print("\(Logger.LABEL_WARNING) : \(message)")
        //Logger.LOGGER.debug("\(Logger.LABEL_WARNING) : \(message)")
        var level=self.level
        if self.level==Logger.LEVEL_DEFAULT { level=WhoFedBlaiseViewModel.getLogLevel() }
        //logger.debug("\(Logger.LABEL_DEBUG) (\(level)) : \(message)")
        if level>=Logger.LEVEL_WARNING { self.log(message,Logger.LEVEL_WARNING ) }
    }

    func error(_ message:String) {
        //print("\(Logger.LABEL_ERROR) : \(message)")
        //Logger.LOGGER.debug("\(Logger.LABEL_ERROR) : \(message)")
        var level=self.level
        if self.level==Logger.LEVEL_DEFAULT { level=WhoFedBlaiseViewModel.getLogLevel() }
        //logger.debug("\(Logger.LABEL_DEBUG) (\(level)) : \(message)")
        if level>=Logger.LEVEL_ERROR { self.log(message,Logger.LEVEL_ERROR) }
    }

    func debug(_ message:String) {
        //print("\(Logger.LABEL_DEBUG) : \(message)")
        //Logger.LOGGER.debug("\(Logger.LABEL_DEBUG) : \(message)")
        var level=self.level
        if self.level==Logger.LEVEL_DEFAULT { level=WhoFedBlaiseViewModel.getLogLevel() }
        //logger.debug("\(Logger.LABEL_DEBUG) (\(level)) : \(message)")
        if level>=Logger.LEVEL_DEBUG { self.log(message,Logger.LEVEL_DEBUG) }
    }

}
