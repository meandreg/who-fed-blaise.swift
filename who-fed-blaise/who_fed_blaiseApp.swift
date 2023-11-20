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
    
    var body: some Scene {
        WindowGroup {
            ContentView(feedingViewModel: feedingViewModel)
        }
    }
}
