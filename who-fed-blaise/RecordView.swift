//
//  RecordView.swift
//  who-fed-blaise
//
//  Created by Guillaume on 02.06.25.
//

import SwiftUI

struct RecordView: View {
    
    @ObservedObject var whoFedBlaiseViewModel: WhoFedBlaiseViewModel
    var feedingRecord: FeedingRecord
    
    static let portionSize:CGSize = if #available(iOS 17, *) {
        CGSize(width:1.0,height:1.0)
    } else {
        CGSize(width:1.5,height:1.0)
    }
    
    //let feedingRecord: FeedingRecord = FeedingViewModel().getFeedingRecord(0)
    
    var body: some View {
        VStack (alignment: .center, spacing: 0) {
            let timestamp = DateFormatters.anyDateFormatter.string(from: feedingRecord.timestamp)
            Text(timestamp)
                .font(.system(size: whoFedBlaiseViewModel.fontsizeTimestamp))
                .frame(maxWidth: .infinity)
            //let portion = String(format: "%.0f", feedingRecord.portion*100)
            HStack {
                if feedingRecord.portion == 1 {
                    //Text(LocalizedStringKey("full-portion"))
                    Label("", systemImage: WhoFedBlaiseViewModel.portionFull)
                        .scaleEffect(RecordView.portionSize)
                } else {
                    Label("", systemImage: WhoFedBlaiseViewModel.portionHalf)
                        .scaleEffect(RecordView.portionSize)
                }
                Label(feedingRecord.alias, systemImage: "person")
            }
            .font(.system(size: whoFedBlaiseViewModel.fontsizeFeeder))
        }
        .hoverEffect(.highlight)
        .padding()
        .swipeActions(edge: .trailing) {
            if feedingRecord.alias==whoFedBlaiseViewModel.alias {
                Button(role: .destructive) {
                    whoFedBlaiseViewModel.delFeedingRecord(feedingRecord: feedingRecord)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .listRowInsets(EdgeInsets())
    }
}
