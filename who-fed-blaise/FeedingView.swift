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
            
            HStack {
                TextField("Pet Name", text: $feedingViewModel.petName)
                    .padding()
                    /*.overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(lineWidth: 1)
                    )*/
                    .autocorrectionDisabled()
                    .onSubmit {
                        feedingViewModel.saveSetting()
                        feedingViewModel.get()
                    }
                
                Label("", systemImage: "arrow.clockwise")
                    .onTapGesture {
                        feedingViewModel.get()
                    }
            }
            .font(.largeTitle)
            
            List {
                ForEach(feedingViewModel.getFeedingRecords(), id: \.timestamp, content: {
                    feedingRecord in
                    RecordView(feedingRecord: feedingRecord)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                feedingViewModel.del(feedingRecord)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .listRowInsets(EdgeInsets())
                })
            }
            .listStyle(.plain)
            
            //.scrollContentBackground(Visibility.hidden)
            
            HStack {
                Text(LocalizedStringKey("full-portion"))
                    .onTapGesture {
                        feedingViewModel.add(1)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(lineWidth: 4)
                    )
                
                Text(LocalizedStringKey("half-portion"))
                    .onTapGesture {
                        feedingViewModel.add(0.5)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(lineWidth: 4)
                    )
            }
            .font(.title3)
        }
    }
}


struct RecordView: View {
    var feedingRecord: FeedingRecord
    
    var body: some View {
        VStack {
            let timestamp = DateFormatters.anyDateFormatter.string(from: feedingRecord.timestamp)
            Text(timestamp)
                .font(.title2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            //let portion = String(format: "%.0f", feedingRecord.portion*100)
            HStack {
                if feedingRecord.portion == 1 {
                    Text(LocalizedStringKey("full-portion"))
                } else {
                    Text(LocalizedStringKey("half-portion"))
                }
                    
                Text(", ")
                Text(LocalizedStringKey("feeder"))
                Text(": \(feedingRecord.feeder)")
                     
            }
        }
        .hoverEffect(.highlight)
        .padding()
    }
}

