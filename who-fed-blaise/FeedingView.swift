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
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
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
            
            Rectangle()
                .frame(maxHeight: .infinity)
                .opacity(0)
            
            List {
                ForEach(feedingViewModel.getFeedingRecords(), id: \.timestamp, content: { feedingRecord in
                    RecordView(feedingViewModel: feedingViewModel, feedingRecord: feedingRecord)
                })
            }
            .listStyle(.plain)
            .opacity(0.5)
            
            
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


