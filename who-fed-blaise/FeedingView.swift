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
        
        VStack {
            
            Text(feedingViewModel.getPetName().uppercased())
                .font(.largeTitle)
                .bold()
            
            ForEach(feedingViewModel.getFeedingRecords(), id: \.timestamp, content: {
                feedingRecord in
                RecordView(feedingViewModel: feedingViewModel, feedingRecord: feedingRecord)
            })
            
            VStack {
                Text(LocalizedStringKey("full-portion"))
                    .onTapGesture {
                        feedingViewModel.add(1)
                    }
                    .font(.largeTitle)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(lineWidth: 4)
                    )
                
                Text(LocalizedStringKey("half-portion"))
                    .onTapGesture {
                        feedingViewModel.add(Int(0.5))
                    }
                    .font(.largeTitle)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(lineWidth: 4)
                    )
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
                //.foregroundColor(.white)
            Text(feedingRecord.feeder)
                //.foregroundColor(.white)
        }
        .onTapGesture {
            feedingViewModel.del(feedingRecord)
        }
        .hoverEffect(.highlight)
        .padding()
    }
}

