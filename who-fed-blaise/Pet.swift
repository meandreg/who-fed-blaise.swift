//
//  PetPickerItem.swift
//  who-fed-blaise
//
//  Created by gude on 02.01.26.
//

import Foundation

struct Pet: Identifiable {
    var id: UUID
    var name: String
    var type: String
    var race: String
    var account: String
    var feeder: String
    var hostname: String
    var port: String
}
