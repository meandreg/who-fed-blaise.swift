//
//  WallPaperView.swift
//  who-fed-blaise
//
//  Created by Guillaume on 13.06.25.
//

import SwiftUI
import PhotosUI

struct WallPaperView: View {
    
    let logger = Logger(Logger.PARAMETER_DEBUG, category: "WallPaperView")
    
    @ObservedObject var feedingViewModel: FeedingViewModel
    @Binding var showPicker: Bool

    @State private var offset = CGSize.zero
    
    var body: some View {
        HStack() {
            VStack(alignment: .leading) {
                Label(LocalizedStringKey("photo-press-long"),systemImage: "pointer.arrow.click.badge.clock")
                Label(LocalizedStringKey("photo-one-tap"), systemImage: "pointer.arrow.click")
                Label(LocalizedStringKey("photo-two-taps"), systemImage: "pointer.arrow.click.2")
                Label(LocalizedStringKey("photo-drag"), systemImage: "hand.draw")
            }
            VStack() {
                Label("",systemImage: "photo")
                Label("", systemImage: "minus.magnifyingglass")
                Label("", systemImage: "plus.magnifyingglass")
                Label("", systemImage: "pointer.arrow.and.square.on.square.dashed")
            }
        }.padding(10)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(lineWidth: 4)
                .opacity(0.5)
        )
        .background(
            Color.gray.opacity(0.5)
        )
        .gesture(
            DragGesture().onChanged{
                gesture in offset = gesture.translation
                feedingViewModel.wallPaperOffsetWidth = offset.width
                feedingViewModel.wallPaperOffsetHeight = offset.height
            }
        )
        .gesture(
            TapGesture(count: 2).onEnded({
                feedingViewModel.wallPaperMagnifyBy = feedingViewModel.wallPaperMagnifyBy/1.2
            }).exclusively(before: TapGesture(count: 1).onEnded({
                feedingViewModel.wallPaperMagnifyBy = feedingViewModel.wallPaperMagnifyBy*1.2
            }))
        )
        .onLongPressGesture(perform: {
            showPicker=true
            logger.debug("Show picker is \(showPicker)")
        })
    }
}
