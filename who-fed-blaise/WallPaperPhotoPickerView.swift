//
//  WallPaperView.swift
//  who-fed-blaise
//
//  Created by Guillaume on 13.06.25.
//

import SwiftUI
import PhotosUI

@available(iOS 17.0, *)
@available(iOS 16.0, *)
struct WallPaperView: View {
    
    @ObservedObject var feedingViewModel: FeedingViewModel
    @State private var selectedPhotoItem:PhotosPickerItem? = nil
    
    @State private var image:UIImage? = nil
    //@State private var magnifyBy = 1.0
    @State private var offset = CGSize.zero
    @State private var showPicker: Bool = false
    
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
                feedingViewModel.wallPaperMagnifyBy = feedingViewModel.wallPaperMagnifyBy*1.2
            }).exclusively(before: TapGesture(count: 1).onEnded({
                feedingViewModel.wallPaperMagnifyBy = feedingViewModel.wallPaperMagnifyBy/1.2
            }))
        )
        .onLongPressGesture(perform: {
            showPicker=true
        })
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
