//
//  Constants.swift
//  who-fed-blaise
//
//  Created by gude on 30.05.26.
//
import Foundation

struct Constants {
    if #available(iOS 17, *) {
        static let portionFull:String = "battery.100percent"
        static let portionHalf:String = "battery.50percent"
    } else {
        static let portionFull:String = "rectangle.fill"
        static let portionHalf:String = "rectangle.lefthalf.filled"
    }
}
