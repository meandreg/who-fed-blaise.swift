//
//  Logger.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 07.10.24.
//

import Foundation
import os

class Role {
    
    let level: Int
    let name: String
    
    init(_ level: Int,_ name: String) {
        self.level = level
        self.name = name
    }
    
    /*ROLE_ROOT=0
    ROLE_DEVELOPER=20
    ROLE_ADMIN=50
    ROLE_USER=100

    ROLE_ACCOUNT_OWNER=0
    ROLE_ACCOUNT_ADMIN=50
    ROLE_ACCOUNT_USER=100

    ROLE_PET_FULL=0
    ROLE_PET_CHILD=50
    ROLE_PET_READONLY=100*/
    
    static let PET_FULL: Int = 0
    static let PET_CHILD: Int = 50
    static let PET_READONLY: Int = 100
    
    static let ACCOUNT_OWNER: Int = 0
    static let ACCOUNT_ADMIN: Int = 50
    static let ACCOUNT_USER: Int =  100
    
    static let ROOT: Int = 0
    static let DEVELOPPER: Int = 20
    static let ADMIN: Int = 50
    static let USER: Int = 100
}
