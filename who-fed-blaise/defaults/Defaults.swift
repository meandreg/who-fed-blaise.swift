//
//  Defaults.swift
//  who-fed-blaise
//
//  Created by gude on 01.12.25.
//

import Foundation
import SwiftUI

struct Defaults {
    //static let ID:UUID
    static let APPNAME:String="who-fed-blaise"
    //static let CUSTOMIZEWALLPAPER:Bool=true
    static let PROTOCOL:String="http"
    static let HOSTNAME:String="hostname"
    static let PORT:String="80"
    static let ACCOUNT:String=""
    static let RECORDNUMBER:Float=3
    static let DEVICETOKEN:String=""
    static let LOGLEVEL:Int=Logger.LEVEL_INFO

    static let PETNAME:String=""
    static let PETTYPE:String=""
    static let PETRACE:String=""
    static let FEEDER:String=""
    static let ALIAS:String=""
    static let PASSWORD:String=""
    static let PORTION:Int=1
    static let FEEDINGNEXT:Float=60*12
    static let NOTIFYBEFORE:Float=60
    static let NOTIFYEVERY:Float=10
    
    static let WALLPAPERNAME:String="Blaise"
    static let WALLPAPERMAGNIFYBY:Double = 2.5
    static let WALLPAPEROFFSETWIDTH:Double = 1.5
    static let WALLPAPEROFFSETHEIGHT:Double = 16
    
    static let FONTSIZE_PETNAME:CGFloat = UIScreen.main.bounds.width/10
    static let FONTSIZE_PETACCOUNT:CGFloat = UIScreen.main.bounds.width/20
    static let FONTSIZE_TIMESTAMP:CGFloat = UIScreen.main.bounds.width/15
    static let FONTSIZE_FEEDER:CGFloat = UIScreen.main.bounds.width/20
    static let FONTSIZE_FOOTER:CGFloat = UIScreen.main.bounds.width/15
    
    static let FOREGROUNDCOLOR:Int = 0
    static let BACKGROUNDCOLOR:Int = 14
    static var COLORNAMES : [LocalizedStringKey] =
        [LocalizedStringKey("color-black")
         ,LocalizedStringKey("color-blue")
         ,LocalizedStringKey("color-brown")
         ,LocalizedStringKey("color-clear")
         ,LocalizedStringKey("color-cyan")
         ,LocalizedStringKey("color-gray")
         ,LocalizedStringKey("color-green")
         ,LocalizedStringKey("color-indigo")
         ,LocalizedStringKey("color-mint")
         ,LocalizedStringKey("color-orange")
         ,LocalizedStringKey("color-pink")
         ,LocalizedStringKey("color-purple")
         ,LocalizedStringKey("color-red")
         ,LocalizedStringKey("color-teal")
         ,LocalizedStringKey("color-white")
         ,LocalizedStringKey("color-yellow")]
    static var COLORS: [Color] = [.black, .blue, .brown, .clear, .cyan, .gray, .green, .indigo, .mint, .orange, .pink, .purple, .red, .teal, .white, .yellow]

}
