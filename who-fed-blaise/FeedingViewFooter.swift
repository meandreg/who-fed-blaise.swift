//
//  ContentView.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 12.05.22.
//

import SwiftUI

struct FeedingViewFooter: View {
    
    let logger = Logger(category: "FeedingViewFooter")
    
    static let portionSize:CGSize = if #available(iOS 17, *) {
        CGSize(width:1.5,height:1.5)
    } else {
        CGSize(width:1.5,height:1.0)
    }
    
    @ObservedObject var wfb: WhoFedBlaiseViewModel
    
    var body: some View {
        HStack() {
            Spacer()
            Label("", systemImage: "textformat.size")
            //.scaleEffect(FeedingViewFooter.portionSize)
            //.padding(4)
                .gesture(
                    TapGesture(count: 2).onEnded({
                        wfb.fontsizeRecord(increase: true)
                    }).exclusively(before: TapGesture(count: 1).onEnded({
                        wfb.fontsizeRecord(increase: false)
                    }))
                )
            Spacer()
            if wfb.canFeed {
                Label("100%", systemImage: WhoFedBlaiseViewModel.portionFull)
                //.scaleEffect(FeedingViewFooter.portionSize)
                    .onTapGesture {
                        wfb.addFeedingRecord(portion: 1)
                    }
                //.padding(4)
                //.foregroundColor(whoFedBlaiseViewModel.feedingColor)
                //.labelStyle(GradientBorderedLabelStyle())
                //Text("100%")
                Spacer()
                Label("50%", systemImage: WhoFedBlaiseViewModel.portionHalf)
                //.scaleEffect(FeedingViewFooter.portionSize)
                    .onTapGesture {
                        wfb.addFeedingRecord(portion: 0.5)
                    }
                //.foregroundColor(whoFedBlaiseViewModel.feedingColor)
                //.padding(4)
                //.border(Color.black, width: 4)
                //Text("50%")
                Spacer()
                if (wfb.feedingRecords.count==1) {
                    Label("", systemImage: "trash")
                        .onTapGesture {
                            wfb.delFeedingRecord(feedingRecord: wfb.feedingRecords[0])
                        }
                        .foregroundColor(wfb.feedingColor)
                        .scaleEffect(1.5)
                    Spacer()
                }
            }
            //.scaleEffect(FeedingViewFooter.portionSize)
            //.padding(4)
            //.font(.system(size: whoFedBlaiseViewModel.fontsizeFooter))
        }
    }
}

struct GradientBorderedLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        Label(configuration)
            .padding(5)
            .border(
                Color.black,
                width: 2
            )
            .cornerRadius(10)
    }
}
