//
//  WallPaperView.swift
//  who-fed-blaise
//
//  Created by Guillaume on 13.06.25.
//


import Photos
import PhotosUI

import SwiftUI

struct WallPaperPHPickerView: View {
    
    let logger = Logger(category: "WallPaperPHPickerView")
    
    @ObservedObject var whoFedBlaiseViewModel: WhoFedBlaiseViewModel
    @State private var showPicker:Bool = false
    @State private var pickedImage:UIImage? = nil
    @State private var imagePicked: Bool = false
    
    var body: some View {
        WallPaperView(whoFedBlaiseViewModel: whoFedBlaiseViewModel, showPicker: $showPicker)
        .sheet(isPresented: $showPicker, content: {
            WallPaperViewControllerRepresentable(showPicker: $showPicker, imagePicked: $imagePicked, pickedImage: $pickedImage)
        })
        //.photosPicker(isPresented: $showPicker, selection: $selectedPhotoItem)
        .onChange(of: pickedImage) { selectedImageChanged in
                //guard let imageData = try await uiImage?.loadTransferable(type: Data.self) else {return}
                //guard let uiImage = UIImage(data: imageData) else {return}
                guard let newImage = pickedImage else {
                        logger.debug("No image selected: \(imagePicked)")
                        return
                }
                logger.debug("New wallpaper image selected: \(imagePicked)")
            WhoFedBlaiseDefaults.saveWallpaperUIImage(whoFedBlaiseViewModel, uiImage: newImage)
            //feedingViewModel.setWallpaperUIImage(uiImage: newImage)
        }
    }
}
