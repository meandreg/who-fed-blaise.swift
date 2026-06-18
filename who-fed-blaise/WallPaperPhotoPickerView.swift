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
    
    @ObservedObject var whoFedBlaiseViewModel: WhoFedBlaiseViewModel
    @State private var selectedPhotoItem:PhotosPickerItem? = nil
    
    @State private var image:UIImage? = nil
    @State private var offset = CGSize.zero
    @State private var showPicker: Bool = false
    
    var body: some View {
        WallPaperView(whoFedBlaiseViewModel: whoFedBlaiseViewModel, showPicker: $showPicker)
        .photosPicker(isPresented: $showPicker, selection: $selectedPhotoItem)
        .onChange(of: selectedPhotoItem) { oldValue, newValue in
            Task{
                guard let imageData = try await selectedPhotoItem?.loadTransferable(type: Data.self) else {return}
                guard let uiImage = UIImage(data: imageData) else {return}
                WhoFedBlaiseDefaults.saveWallpaperUIImage(whoFedBlaiseViewModel, uiImage: uiImage)
                whoFedBlaiseViewModel.wallpaperImage = WhoFedBlaiseDefaults.getWallpaperImage(whoFedBlaiseViewModel)
            }
        }
    }
}
