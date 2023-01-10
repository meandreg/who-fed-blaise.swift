//
//  ContentView.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 12.05.22.
//

import SwiftUI

struct FeedingView: View {

    @ObservedObject var feedingViewModel: FeedingViewModel

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
                
               VStack {
                    
                   Text(feedingViewModel.getPetName().uppercased())
                        .font(.largeTitle)
                        .bold()
                    
                   ForEach(feedingViewModel.getFeedingRecords(), id: \.timestamp, content: {
                       feedingRecord in
                       RecordView(feedingViewModel: feedingViewModel, feedingRecord: feedingRecord)
                   })
                   
                   HStack {
                       Text(LocalizedStringKey("full-portion")).onTapGesture {
                           feedingViewModel.add(1)
                        }
                        .font(.largeTitle)
                        .padding()
                        
                        Text(LocalizedStringKey("half-portion")).onTapGesture {
                            feedingViewModel.add(0,5)
                        }
                        .font(.largeTitle)
                        .padding()
                    }
                }
            }
        }
    }
}

struct RecordView: View {
    var feedingViewModel: FeedingViewModel
    var feedingRecord: FeedingRecord
    
    var body: some View {
        VStack {
            Text(DateFormatters.iso8601DateFormatter.string(from: feedingRecord.timestamp))
                .font(.title)
                .foregroundColor(.white)
            Text(feedingRecord.feeder)
                .foregroundColor(.white)
        }
        .onTapGesture {
            feedingViewModel.del(feedingRecord)
        }
        .padding()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let feedingViewModel = FeedingViewModel()
        FeedingView(feedingViewModel: feedingViewModel)
    }
}
