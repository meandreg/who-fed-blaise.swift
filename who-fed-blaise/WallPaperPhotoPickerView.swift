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
    
    let logger = Logger(category: "WallPaperPhotoPickerView")
    
    @ObservedObject var wfb: WhoFedBlaiseViewModel
    @State private var selectedPhotoItem:PhotosPickerItem? = nil
    
    @State private var image:UIImage? = nil
    @State private var offset = CGSize.zero
    @State private var showPicker: Bool = false
    
    var body: some View {
        WallPaperView(wfb: wfb, showPicker: $showPicker)
        .photosPicker(isPresented: $showPicker, selection: $selectedPhotoItem)
        .onChange(of: selectedPhotoItem) { oldValue, newValue in
            Task {
                await loadImage(from: newValue)
                /*do {
                    wfb.logger.info("Change wallpaperImage")
                    guard let imageData = try await selectedPhotoItem?.loadTransferable(type: Data.self) else {return}
                    guard let uiImage = UIImage(data: imageData) else {return}
                    WhoFedBlaiseDefaults.saveWallpaperUIImage(wfb, uiImage: uiImage)
                    wfb.wallpaperImage = WhoFedBlaiseDefaults.getWallpaperImage(wfb)
                    wfb.logger.debug("Successfully changed wallpaperImage")
                } catch {
                    wfb.logger.error("Failed to set wallpaperImage \(error)")
                }*/
            }
        }
    }
    
    private func loadImage(from item: PhotosPickerItem?) async {
        do {
            logger.info("Change wallpaperImage")
            guard let imageData = try await selectedPhotoItem?.loadTransferable(type: Data.self) else {return}
            guard let uiImage = UIImage(data: imageData) else {return}
            WhoFedBlaiseDefaults.saveWallpaperUIImage(wfb, uiImage: uiImage)
            wfb.wallpaperImage = WhoFedBlaiseDefaults.getWallpaperImage(wfb)
            logger.debug("Successfully changed wallpaperImage")
        } catch {
            logger.error("Failed to set wallpaperImage \(error)")
        }
    }
}
