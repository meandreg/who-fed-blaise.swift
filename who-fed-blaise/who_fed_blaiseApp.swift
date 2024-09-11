//
//  who_fed_blaiseApp.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 12.05.22.
//

import SwiftUI

@main
struct who_fed_blaiseApp: App {
    
    @StateObject var feedingViewModel = FeedingViewModel()
    //@StateObject var settingViewModel = SettingViewModel()
    
    var body: some Scene {
        WindowGroup {
            //NotificationRequestView()
            ContentView(feedingViewModel: feedingViewModel)
        }
    }
}

