//
//  ContentView.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 12.05.22.
//

import SwiftUI

struct FeedingViewHeader: View {
    
    let logger = Logger(category: "FeedingViewHeader")
    
    @ObservedObject var whoFedBlaiseViewModel: WhoFedBlaiseViewModel
    
    var body: some View {
        HStack {
            VStack {
                Label("", systemImage: "gearshape")
                    .onTapGesture {
                        whoFedBlaiseViewModel.selectedPetConfig = true
                    }
                Label("", systemImage: "photo")
                    .onTapGesture {
                        whoFedBlaiseViewModel.selectedPetPhoto = true
                    }
                Label("", systemImage: "textformat.size")
                    .gesture(
                        TapGesture(count: 2).onEnded({
                            whoFedBlaiseViewModel.fontsizeHeader(increase: true)
                        }).exclusively(before: TapGesture(count: 1).onEnded({
                            whoFedBlaiseViewModel.fontsizeHeader(increase: false)
                        }))
                    )
            }
            Spacer()
            PetNameView(whoFedBlaiseViewModel: whoFedBlaiseViewModel)
            Spacer()
            if whoFedBlaiseViewModel.selectedPetPicker {
                Label("", systemImage: "checkmark.circle")
                    .onTapGesture {
                        whoFedBlaiseViewModel.selectedPetPicker = false
                    }
            } else {
                if whoFedBlaiseViewModel.selectedPets.isMultiple {
                    Label("", systemImage: "checklist")
                        .onTapGesture {
                            whoFedBlaiseViewModel.selectedPetPicker = true
                        }
                }
            }
        }
    }
}
