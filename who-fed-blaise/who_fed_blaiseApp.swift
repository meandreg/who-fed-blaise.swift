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
    //@EnvironmentObject private var appDelegate: MyAppDelegate
    //@EnvironmentObject private var whoFedBlaiseViewModel: WhoFedBlaiseViewModel
    
    @StateObject var whoFedBlaiseViewModel = WhoFedBlaiseViewModel()

    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView(whoFedBlaiseViewModel: whoFedBlaiseViewModel)
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        UIApplication.shared.applicationIconBadgeNumber = 0
                    }
                }
        }
    }
}

func isSimulator() -> Bool {
    #if targetEnvironment(simulator)
        return true
    #else
        return false
    #endif
}
