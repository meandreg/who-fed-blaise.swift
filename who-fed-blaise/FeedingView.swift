//
//  ContentView.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 12.05.22.
//

import SwiftUI

struct FeedingView: View {
    
    let logger = Logger(category: "FeedingView")
    
    @Environment(\.scenePhase) var scenePhase

    @ObservedObject var wfb: WhoFedBlaiseViewModel
    
    @State private var offset = CGSize.zero
    
    var body: some View {
        VStack {
            FeedingViewHeader(wfb: wfb)
            
            Spacer()
            
            if #available(iOS 17.0, *) {
                FeedingListView(wfb: wfb)
                    .onChange(of: scenePhase) { oldPhase, newPhase in
                        if newPhase == .active {
                            logger.info("Active")
                            wfb.getFeedingRecords()
                        } else if newPhase == .inactive {
                            logger.info("Inactive")
                        } else if newPhase == .background {
                            logger.info("Background")
                        }
                    }
            } else {
                FeedingListView(wfb: wfb)
            }
            FeedingViewFooter(wfb: wfb)
            Rectangle()
                .frame(maxHeight: 5)
                .opacity(0.001)
        }
        .font(.system(size: wfb.fontsizeFooter))
    }
}

struct FeedingListView: View {
    @ObservedObject var wfb: WhoFedBlaiseViewModel
    
    var body: some View {
        if Int(wfb.recordNumber)<=1 {
                RecordView(wfb: wfb, feedingRecord: wfb.feedingRecords[0])
        } else {
            List {
                ForEach(wfb.feedingRecords, id: \.timestamp, content: { feedingRecord in
                    RecordView(wfb: wfb, feedingRecord: feedingRecord)
                })
            }
            .listStyle(.plain)
            .opacity(Double(wfb.opacity/100))
            .frame(maxHeight: UIScreen.main.bounds.height * 0.3)
        }
    }
}
