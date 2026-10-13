//
//  ContentView.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 12.05.22.
//

import SwiftUI

struct FeedingViewHeader: View {
    
    let logger = Logger(category: "FeedingViewHeader")
    
    @ObservedObject var wfb: WhoFedBlaiseViewModel
    
    var body: some View {
        HStack {
            VStack {
                Label("", systemImage: "gearshape")
                    .onTapGesture {
                        wfb.selectedPetConfig = true
                    }
                Label("", systemImage: "photo")
                    .onTapGesture {
                        wfb.selectedPetPhoto = true
                    }
                Label("", systemImage: "textformat.size")
                    .gesture(
                        TapGesture(count: 2).onEnded({
                            wfb.fontsizeHeader(increase: true)
                        }).exclusively(before: TapGesture(count: 1).onEnded({
                            wfb.fontsizeHeader(increase: false)
                        }))
                    )
            }
            Spacer()
            PetNameView(whoFedBlaiseViewModel: wfb)
            Spacer()
            if wfb.selectedPets.isMultiple {
                if wfb.selectedPetPicker {
                    Label("", systemImage: "checkmark.circle")
                        .onTapGesture {
                        wfb.selectedPetPicker = false
                    }
                } else {
                    Label("", systemImage: "checklist")
                        .onTapGesture {
                            wfb.selectedPetPicker = true
                        }
                }
            }
        }
    }
}
