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
    
    @ObservedObject var wfb: WhoFedBlaiseViewModel
    @Binding var showPicker: Bool
    @State private var selectedColor: Color = .black
    @State private var showdColorPicker: Bool = false
    
    @State private var offset = CGSize.zero
    @State private var showColorPicker: Bool = true
    
    var body: some View {
        VStack {
            Label("", systemImage: "pawprint")
                .onTapGesture {
                    wfb.save()
                    wfb.selectedPetPhoto = false
                }
            Spacer()
            VStack() {
                HStack() {
                    Label(LocalizedStringKey("photo-press-long"),systemImage: "pointer.arrow.click.badge.clock")
                    Spacer()
                    Label("",systemImage: "photo")
                }
                .background(Defaults.COLORS[wfb.backgroundColor])
                HStack() {
                    Label(LocalizedStringKey("photo-one-tap"), systemImage: "pointer.arrow.click")
                    Spacer()
                    Label("", systemImage: "minus.magnifyingglass")
                }
                .background(Defaults.COLORS[wfb.backgroundColor])
                HStack() {
                    Label(LocalizedStringKey("photo-two-taps"), systemImage: "pointer.arrow.click.2")
                    Spacer()
                    Label("", systemImage: "plus.magnifyingglass")
                }
                .background(Defaults.COLORS[wfb.backgroundColor])
                HStack() {
                    Label(LocalizedStringKey("photo-drag"), systemImage: "hand.draw")
                    Spacer()
                    Label("", systemImage: "pointer.arrow.and.square.on.square.dashed")
                }
                .background(Defaults.COLORS[wfb.backgroundColor])
            }
            .gesture(
                DragGesture().onChanged{
                    gesture in offset = gesture.translation
                    wfb.wallpaperOffsetWidth = offset.width
                    wfb.wallpaperOffsetHeight = offset.height
                }
            )
            .gesture(
                TapGesture(count: 2)
                .onEnded({
                    wfb.wallpaperMagnifyBy = wfb.wallpaperMagnifyBy*1.2
                    logger.debug("Two (2) taps \(wfb.wallpaperMagnifyBy)")
                })
                .exclusively(before: TapGesture(count: 1)
                    .onEnded({
                        wfb.wallpaperMagnifyBy = wfb.wallpaperMagnifyBy/1.2
                            logger.debug("One (1) taps \(wfb.wallpaperMagnifyBy)")
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
                Picker("ColorPicker", selection: $wfb.foregroundColor,
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
            .background(Defaults.COLORS[wfb.backgroundColor])
            HStack() {
                Text(LocalizedStringKey("photo-background"))
                Spacer()
                Picker("ColorPicker", selection: $wfb.backgroundColor,
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
            .background(Defaults.COLORS[wfb.backgroundColor])
            
            SliderText(min: 0, max: 100,
                       label1: LocalizedStringKey(Labels.OPACITY),
                       label2: "%",
                       variable: $wfb.opacity,
                       modulo:  1
            )
            .background(Defaults.COLORS[wfb.backgroundColor])
            Spacer()
        }
        .padding(10)
        /*.overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(lineWidth: 4)
                .opacity(0.1)
        )*/
        .opacity(Double(wfb.opacity/100))
        //.background(Color.gray.opacity(0.8))
    }
}
