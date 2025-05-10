//
//  DateFormatters.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 18.09.24.
//

import Foundation

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
        dateFormatter.formatOptions = [.withFractionalSeconds,.withInternetDateTime]
        return dateFormatter
   }
    
    static var mariadbDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        //dateFormatter.locale = Locale(identifier: "GMT")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
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

