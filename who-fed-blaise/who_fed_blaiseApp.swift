//
//  who_fed_blaiseApp.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 12.05.22.
//

import SwiftUI

@main
struct who_fed_blaiseApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject var feedingViewModel = FeedingViewModel()

    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            //NotificationRequestView()
            ContentView(feedingViewModel: feedingViewModel)
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        UIApplication.shared.applicationIconBadgeNumber = 0
                    }
                }
        }
    }
}

