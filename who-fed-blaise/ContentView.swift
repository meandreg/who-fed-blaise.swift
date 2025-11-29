//
//  ContentView.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 12.05.22.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var feedingViewModel: FeedingViewModel

    @State private var selection = 0
    
    let logger = Logger(Logger.PARAMETER_DEBUG, category: "ContentView")
    
    var body: some View {
        ZStack {
            TabView (selection: $selection,
                content:  {
                    FeedingView(feedingViewModel: feedingViewModel)
                        .tabItem {
                            Label(LocalizedStringKey("feeding-board"), systemImage: "list.bullet.rectangle")
                        }
                        .tag(0)
                        .onAppear(perform: {
                            NotificationManager.notificatioManager.requestNotification()
                            feedingViewModel.get()
                        })
                        .background(
                            FeedingViewBackgroundView(feedingViewModel: feedingViewModel)
                        )
                
                FeedingViewClaire(feedingViewModel: feedingViewModel)
                    .tabItem {
                        Label(LocalizedStringKey("for-claire"), systemImage: "heart.fill")
                    }
                    .tag(1)
                    .onAppear(perform: {
                        NotificationManager.notificatioManager.requestNotification()
                        feedingViewModel.get()
                    })
                    .background(
                        FeedingViewBackgroundView(feedingViewModel: feedingViewModel)
                    )
                
                SettingView(feedingViewModel: feedingViewModel)
                    .tabItem {
                        Label(LocalizedStringKey("setting"), systemImage: "gearshape")
                    }
                    .tag(2)
                
                if #available(iOS 17.0, *) {
                    WallPaperPhotoPickerView(feedingViewModel: feedingViewModel)
                        .tabItem {
                            Label("WallPaper", systemImage: "photo")
                        }
                        .tag(3)
                        .background(
                            FeedingViewBackgroundView(feedingViewModel: feedingViewModel)
                        )
                } else {
                    WallPaperPHPickerView(feedingViewModel: feedingViewModel)
                        .tabItem {
                            Label("WallPaper", systemImage: "photo")
                        }
                        .tag(3)
                        .background(
                            FeedingViewBackgroundView(feedingViewModel: feedingViewModel)
                        )
                }
                
            })
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(feedingViewModel: FeedingViewModel())
        }
    }
}
