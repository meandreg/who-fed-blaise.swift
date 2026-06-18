//
//  FeedingViewBackgroundView.swift
//  who-fed-blaise
//
//  Created by gude on 29.11.25.
//

import SwiftUI
import PhotosUI

struct FeedingViewBackgroundView: View {
    
    let logger = Logger(category: "FeedingViewBacgroundView")
    
    @ObservedObject var whoFedBlaiseViewModel: WhoFedBlaiseViewModel
    
    var body: some View {
        whoFedBlaiseViewModel.wallpaperImage
            .scaleEffect(CGSize(width: whoFedBlaiseViewModel.wallpaperMagnifyBy,height: whoFedBlaiseViewModel.wallpaperMagnifyBy))
            .offset(CGSize(width: whoFedBlaiseViewModel.wallpaperOffsetWidth,height: whoFedBlaiseViewModel.wallpaperOffsetHeight))
    }
}
