//
//  RecordView.swift
//  who-fed-blaise
//
//  Created by Guillaume on 02.06.25.
//

import SwiftUI

struct RecordView: View {
    
    @ObservedObject var feedingViewModel: FeedingViewModel
    var feedingRecord: FeedingRecord
    //let feedingRecord: FeedingRecord = FeedingViewModel().getFeedingRecord(0)
    
    var body: some View {
        VStack (alignment: .center, spacing: 0) {
            let timestamp = DateFormatters.anyDateFormatter.string(from: feedingRecord.timestamp)
            Text(timestamp)
                .font(.title2)
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
                Text(": \(feedingRecord.alias)")
                     
            }
        }
        .hoverEffect(.highlight)
        .padding()
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                feedingViewModel.del(feedingRecord)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .listRowInsets(EdgeInsets())
    }
}
