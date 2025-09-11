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
   /* @State var wallPaperImage: Image = Parameters.getWallPaperImage()
    @State var wallPaperUIImage: UIImage? = Parameters.getWallPaperUIImage()
    @State var customizeWallPaper: Bool = Parameters.getCustomizeWallPaper()*/
    
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
                        feedingViewModel.wallPaperImage.resizable()
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
                        feedingViewModel.wallPaperImage.resizable()
                    )
                
                SettingView(feedingViewModel: feedingViewModel)
                    .tabItem {
                        Label(LocalizedStringKey("setting"), systemImage: "gearshape")
                    }
                    .tag(2)
                
                WallPaperView(feedingViewModel: feedingViewModel)
                    .tabItem {
                        Label("WallPaper", systemImage: "photo")
                    }
                    .tag(3)
                    .background(
                        feedingViewModel.wallPaperImage.resizable()
                    )
                    .onTapGesture(perform: {
                        feedingViewModel.customizeWallPaper.toggle()
                    })
            })
        }
        .sheet(isPresented: $feedingViewModel.customizeWallPaper) {
            WallPaperViewController(wallPaperUIImage: $feedingViewModel.wallPaperUIImage)
        }
        .onChange(of: feedingViewModel.wallPaperUIImage) { _ in feedingViewModel.loadWallPaperImage() }
    }
    /*
    func loadImage() {
        guard let uiImage = feedingViewModel.wallPaperUIImage else { return }
        feedingViewModel.wallPaperImage = Image(uiImage: uiImage)
    }
    */
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(feedingViewModel: FeedingViewModel())
        }
    }
}
