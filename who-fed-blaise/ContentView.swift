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

    var body: some View {
        
        //GeometryReader {
            //geo in
            
            ZStack {
                /*Image("Wallpaper")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                    .opacity(1.0)*/
                
                TabView (selection: $selection,
                         content:  {
                    FeedingView(feedingViewModel: feedingViewModel)
                        .tabItem {
                            Label("Feeding Board", systemImage: "basket")
                        }
                        .tag(0)
                        .onAppear(perform: {
                            NotificationManager.notificatioManager.requestNotification()
                            feedingViewModel.get()
                        })
                        .background(
                            Image("Wallpaper")
                            .resizable()
                            )
                    
                    SettingView(feedingViewModel: feedingViewModel)
                    .tabItem {
                        Label("Setting", systemImage: "gearshape")
                    }
                    .tag(1)
                })
            }
        //}
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(feedingViewModel: FeedingViewModel())
        }
    }
}
