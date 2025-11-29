//
//  WallPaperView.swift
//  who-fed-blaise
//
//  Created by Guillaume on 13.06.25.
//

import SwiftUI
import PhotosUI

@available(iOS 17.0, *)
struct WallPaperPhotoPickerView: View {
    
    @ObservedObject var feedingViewModel: FeedingViewModel
    @State private var selectedPhotoItem:PhotosPickerItem? = nil
    
    @State private var image:UIImage? = nil
    @State private var offset = CGSize.zero
    @State private var showPicker: Bool = false
    
    var body: some View {
        WallPaperView(feedingViewModel: feedingViewModel, showPicker: $showPicker)
        .photosPicker(isPresented: $showPicker, selection: $selectedPhotoItem)
        .onChange(of: selectedPhotoItem) { oldValue, newValue in
            Task{
                guard let imageData = try await selectedPhotoItem?.loadTransferable(type: Data.self) else {return}
                guard let uiImage = UIImage(data: imageData) else {return}
                Parameters.setWallPaperUIImage(uiImage)
                feedingViewModel.wallPaperImage = Parameters.getWallPaperImage()
            }
        }
    }
}
