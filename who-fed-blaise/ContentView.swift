//
//  ContentView.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 12.05.22.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var feedingViewModel: FeedingViewModel
    //@State var urlSessionModel: urlSes
    @State var petName: String
    @State var url: String
    @State var recordNumber: Int
 
    init(feedingViewModel: FeedingViewModel) {
        self.feedingViewModel = feedingViewModel
        self.petName = feedingViewModel.getPetName()
        self.url = feedingViewModel.getUrl()
        self.recordNumber = feedingViewModel.getRecordsNumber()
    }

    var body: some View {
        
        GeometryReader {
            geo in
            
            ZStack {
                Image("Wallpaper")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                    .opacity(1.0)
                
                TabView {
                    FeedingView(feedingViewModel: feedingViewModel)
                        .tabItem {
                            Label("Feeding Board", systemImage: "basket")
                    }

                    SettingView(
                        petName: $petName,
                        url: $url,
                        recordNumber: $recordNumber
                        )
                        .tabItem {
                            Label("Setting", systemImage: "gearshape")
                    }
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let feedingViewModel = FeedingViewModel()
        ContentView(feedingViewModel: feedingViewModel)
    }
}
