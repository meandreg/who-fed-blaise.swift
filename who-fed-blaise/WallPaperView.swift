//
//  WallPaperView.swift
//  who-fed-blaise
//
//  Created by Guillaume on 13.06.25.
//

import SwiftUI
import PhotosUI

struct WallPaperView: View {
    
    let logger = Logger(category: "WallPaperView")
    
    @ObservedObject var whoFedBlaiseViewModel: WhoFedBlaiseViewModel
    @Binding var showPicker: Bool
    @State private var selectedColor: Color = .black
    @State private var showdColorPicker: Bool = false
    
    @State private var offset = CGSize.zero
    @State private var showColorPicker: Bool = true
    
    var body: some View {
        VStack {
            Label("", systemImage: "pawprint")
                .onTapGesture {
                    WhoFedBlaiseDefaults.save(whoFedBlaiseViewModel)
                    whoFedBlaiseViewModel.selectedPetPhoto = false
                }
            Spacer()
            VStack() {
                HStack() {
                    Label(LocalizedStringKey("photo-press-long"),systemImage: "pointer.arrow.click.badge.clock")
                    Spacer()
                    Label("",systemImage: "photo")
                }
                .background(Defaults.COLORS[whoFedBlaiseViewModel.backgroundColor])
                HStack() {
                    Label(LocalizedStringKey("photo-one-tap"), systemImage: "pointer.arrow.click")
                    Spacer()
                    Label("", systemImage: "minus.magnifyingglass")
                }
                .background(Defaults.COLORS[whoFedBlaiseViewModel.backgroundColor])
                HStack() {
                    Label(LocalizedStringKey("photo-two-taps"), systemImage: "pointer.arrow.click.2")
                    Spacer()
                    Label("", systemImage: "plus.magnifyingglass")
                }
                .background(Defaults.COLORS[whoFedBlaiseViewModel.backgroundColor])
                HStack() {
                    Label(LocalizedStringKey("photo-drag"), systemImage: "hand.draw")
                    Spacer()
                    Label("", systemImage: "pointer.arrow.and.square.on.square.dashed")
                }
                .background(Defaults.COLORS[whoFedBlaiseViewModel.backgroundColor])
            }
            .gesture(
                DragGesture().onChanged{
                    gesture in offset = gesture.translation
                    whoFedBlaiseViewModel.wallpaperOffsetWidth = offset.width
                    whoFedBlaiseViewModel.wallpaperOffsetHeight = offset.height
                }
            )
            .gesture(
                TapGesture(count: 2)
                .onEnded({
                    whoFedBlaiseViewModel.wallpaperMagnifyBy = whoFedBlaiseViewModel.wallpaperMagnifyBy*1.2
                    logger.debug("Two (2) taps \(whoFedBlaiseViewModel.wallpaperMagnifyBy)")
                })
                .exclusively(before: TapGesture(count: 1)
                    .onEnded({
                        whoFedBlaiseViewModel.wallpaperMagnifyBy = whoFedBlaiseViewModel.wallpaperMagnifyBy/1.2
                            logger.debug("One (1) taps \(whoFedBlaiseViewModel.wallpaperMagnifyBy)")
                    })
                )
            )
            .onLongPressGesture(perform: {
                showPicker=true
                logger.debug("Show picker is \(showPicker)")
            })
        
            HStack() {
                Text(LocalizedStringKey("photo-color"))
                Spacer()
                //Label("", systemImage: "pointer.arrow.and.square.on.square.dashed")
                Picker("ColorPicker", selection: $whoFedBlaiseViewModel.foregroundColor,
                       content: {
                    ForEach(Array(Defaults.COLORNAMES.enumerated()), id: \.offset) {index , element in
                        Text(element)
                            .tag(index)
                            .foregroundStyle(Defaults.COLORS[index])
                    }
                }
                )
                .pickerStyle(.menu)
            }
            .background(Defaults.COLORS[whoFedBlaiseViewModel.backgroundColor])
            HStack() {
                Text(LocalizedStringKey("photo-background"))
                Spacer()
                Picker("ColorPicker", selection: $whoFedBlaiseViewModel.backgroundColor,
                       content: {
                    ForEach(Array(Defaults.COLORNAMES.enumerated()), id: \.offset) {index , element in
                        Text(element)
                            .tag(index)
                            .foregroundStyle(Defaults.COLORS[index])
                    }
                }
                )
                .pickerStyle(.menu)
            }
            .background(Defaults.COLORS[whoFedBlaiseViewModel.backgroundColor])
            
            SliderText(min: 0, max: 100,
                       label1: LocalizedStringKey(Labels.OPACITY),
                       label2: "%",
                       variable: $whoFedBlaiseViewModel.opacity,
                       modulo:  1
            )
            .background(Defaults.COLORS[whoFedBlaiseViewModel.backgroundColor])
            Spacer()
        }
        .padding(10)
        /*.overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(lineWidth: 4)
                .opacity(0.1)
        )*/
        .opacity(Double(whoFedBlaiseViewModel.opacity/100))
        //.background(Color.gray.opacity(0.8))
    }
}
