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

    @ObservedObject var whoFedBlaiseViewModel: WhoFedBlaiseViewModel
    
    @State private var offset = CGSize.zero
    
    var body: some View {
        VStack {
            FeedingViewHeader(whoFedBlaiseViewModel: whoFedBlaiseViewModel)
            /*Rectangle()
                .frame(maxHeight: .infinity)
                .opacity(0.001)*/
            Spacer()
            /*if Int(whoFedBlaiseViewModel.recordNumber)<=1 || whoFedBlaiseViewModel.role<Role.ROLE_LEVEL_USER || whoFedBlaiseViewModel.feedingRecords.count<=1 {
                if whoFedBlaiseViewModel.feedingRecords.count>=1 {
                    RecordView(whoFedBlaiseViewModel: whoFedBlaiseViewModel, feedingRecord: whoFedBlaiseViewModel.feedingRecords[0])
                }
            } else {
                List {
                    ForEach(whoFedBlaiseViewModel.feedingRecords, id: \.timestamp, content: { feedingRecord in
                        RecordView(whoFedBlaiseViewModel: whoFedBlaiseViewModel, feedingRecord: feedingRecord)
                    })
                }
                .listStyle(.plain)
                .opacity(Double(whoFedBlaiseViewModel.opacity/100))
                .frame(maxHeight: UIScreen.main.bounds.height * 0.3)
            }*/
            
            if #available(iOS 17.0, *) {
                FeedingListView(whoFedBlaiseViewModel: whoFedBlaiseViewModel)
                    .onChange(of: scenePhase) { oldPhase, newPhase in
                        if newPhase == .active {
                            logger.info("Active")
                            whoFedBlaiseViewModel.getFeedingRecords()
                        } else if newPhase == .inactive {
                            logger.info("Inactive")
                        } else if newPhase == .background {
                            logger.info("Background")
                        }
                    }
            } else {
                FeedingListView(whoFedBlaiseViewModel: whoFedBlaiseViewModel)
            }
            FeedingViewFooter(whoFedBlaiseViewModel: whoFedBlaiseViewModel)
            Rectangle()
                .frame(maxHeight: 5)
                .opacity(0.001)
        }
        .font(.system(size: whoFedBlaiseViewModel.fontsizeFooter))
    }
}

struct FeedingListView: View {
    @ObservedObject var whoFedBlaiseViewModel: WhoFedBlaiseViewModel
    
    var body: some View {
        if Int(whoFedBlaiseViewModel.recordNumber)<=1 || whoFedBlaiseViewModel.role<Role.ROLE_LEVEL_USER || whoFedBlaiseViewModel.feedingRecords.count<=1 {
            if whoFedBlaiseViewModel.feedingRecords.count>=1 {
                RecordView(whoFedBlaiseViewModel: whoFedBlaiseViewModel, feedingRecord: whoFedBlaiseViewModel.feedingRecords[0])
            }
        } else {
            List {
                ForEach(whoFedBlaiseViewModel.feedingRecords, id: \.timestamp, content: { feedingRecord in
                    RecordView(whoFedBlaiseViewModel: whoFedBlaiseViewModel, feedingRecord: feedingRecord)
                })
            }
            .listStyle(.plain)
            .opacity(Double(whoFedBlaiseViewModel.opacity/100))
            .frame(maxHeight: UIScreen.main.bounds.height * 0.3)
        }
    }
}
