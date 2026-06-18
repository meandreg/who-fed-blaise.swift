//
//  ContentView.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 12.05.22.
//

import SwiftUI

struct PetNameView: View {
    
    let logger = Logger(category: "PetNameView")

    @ObservedObject var whoFedBlaiseViewModel: WhoFedBlaiseViewModel
    
    var body: some View {
        VStack {
            if whoFedBlaiseViewModel.selectedPetPicker {
                Picker(LocalizedStringKey(Labels.PETNAME),
                    selection: $whoFedBlaiseViewModel.id,
                        content: {
                    ForEach(whoFedBlaiseViewModel.selectedPets.pets) {pet in
                            Text(pet.name+"\n(@) "+pet.account)
                        }
                    })
                    .pickerStyle(.menu)
                    .onChange(of: whoFedBlaiseViewModel.id, perform: { newId in
                        whoFedBlaiseViewModel.switchTo(newId)
                        whoFedBlaiseViewModel.selectedPetPicker = false
                    })
            } else {
                Text(whoFedBlaiseViewModel.name)
                    .font(.system(size: whoFedBlaiseViewModel.fontsizePetName))
                if (whoFedBlaiseViewModel.account==whoFedBlaiseViewModel.feeder)   {
                    Label("(@) "+whoFedBlaiseViewModel.alias, systemImage: "person")
                        .font(.system(size: whoFedBlaiseViewModel.fontsizePetAccount))
                } else {
                    Text("(@) "+whoFedBlaiseViewModel.account)
                        .font(.system(size: whoFedBlaiseViewModel.fontsizePetAccount))
                    Label(whoFedBlaiseViewModel.alias, systemImage: "person")
                        .font(.system(size: whoFedBlaiseViewModel.fontsizePetAccount))
                }
            }
        }
    }
}


