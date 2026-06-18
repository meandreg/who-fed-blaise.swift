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
    
    static let ROLE_ROOT="root"
    static let ROLE_ADMIN="admin"
    static let ROLE_OWNER="owner"
    static let ROLE_USER="user"
    static let ROLE_CHILD="child"
    static let ROLE_READ="READ"
    
    static let ROLE_LEVEL_READ: Int = 0
    static let ROLE_LEVEL_CHILD: Int = 10
    static let ROLE_LEVEL_USER: Int = 100
    static let ROLE_LEVEL_OWNER: Int = 1000
    static let ROLE_LEVEL_ADMIN: Int = 10000
    static let ROLE_LEVEL_ROOT: Int =  100000
    static let ROLE_LEVEL_DEFAULT: Int =  ROLE_LEVEL_READ
    
    static let ROLES: [Role] = [Role(ROLE_LEVEL_READ,ROLE_READ),Role(ROLE_LEVEL_CHILD,ROLE_CHILD),Role(ROLE_LEVEL_USER,ROLE_USER),Role(ROLE_LEVEL_OWNER,ROLE_OWNER),Role(ROLE_LEVEL_ADMIN,ROLE_ADMIN),Role(ROLE_LEVEL_ROOT,ROLE_ROOT)]
        
    static func getRoleLevel(_ name: String)->Int{
        for role in ROLES {
            if role.name == name {
                return role.level
            }
        }
        return -1
    }
    
    static func getRoleName(_ level: Int)->String{
        for role in ROLES {
            if role.level == level {
                return role.name
            }
        }
        return "unknown"
    }
}
