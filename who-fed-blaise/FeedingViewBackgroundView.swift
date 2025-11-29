//
//  FeedingViewBackgroundView.swift
//  who-fed-blaise
//
//  Created by gude on 29.11.25.
//

import SwiftUI
import PhotosUI

struct FeedingViewBackgroundView: View {
    
    let logger = Logger(Logger.PARAMETER_DEBUG, category: "FeedingViewBacgroundView")
    
    @ObservedObject var feedingViewModel: FeedingViewModel
    
    var body: some View {
        feedingViewModel.wallPaperImage
            .scaleEffect(CGSize(width: feedingViewModel.wallPaperMagnifyBy,height: feedingViewModel.wallPaperMagnifyBy))
            .offset(CGSize(width: feedingViewModel.wallPaperOffsetWidth,height: feedingViewModel.wallPaperOffsetHeight))
    }
}
