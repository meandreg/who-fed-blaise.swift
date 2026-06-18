//
//  ContentView.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 12.05.22.
//

import SwiftUI

struct FeedingView: View {
    
    let logger = Logger(Logger.PARAMETER_DEBUG, category: "FeedingView")

    @ObservedObject var whoFedBlaiseViewModel: WhoFedBlaiseViewModel
    
    @State private var offset = CGSize.zero
    
    var body: some View {
            VStack {
                VStack() {
                    HStack {
                        Label("", systemImage: "gearshape")
                            .onTapGesture {
                                whoFedBlaiseViewModel.selectedPetConfig = true
                            }
                        Spacer()
                        if whoFedBlaiseViewModel.selectedPetPicker {
                            Picker(LocalizedStringKey(Labels.PETNAME),
                                   selection: $whoFedBlaiseViewModel.id,
                                   content: {
                                ForEach(whoFedBlaiseViewModel.selectedPets) {pet in
                                    Text(pet.name+" ("+pet.account+")")
                                        .tag(pet.id)
                                }
                            })
                            .pickerStyle(.menu)
                            .onChange(of: whoFedBlaiseViewModel.id, perform: { newId in
                                whoFedBlaiseViewModel.switchTo(newId)
                                whoFedBlaiseViewModel.getFeedingRecords()
                                whoFedBlaiseViewModel.selectedPetPicker = false
                            })
                            Spacer()
                            Label("", systemImage: "checkmark.circle")
                                .onTapGesture {
                                        whoFedBlaiseViewModel.selectedPetPicker = false
                                }
                        } else {
                            Text(whoFedBlaiseViewModel.name)
                                .font(.title)
                            Spacer()
                            if whoFedBlaiseViewModel.selectedPets.count > 1 {
                                Label("", systemImage: "checklist")
                                    .onTapGesture {
                                        if whoFedBlaiseViewModel.selectedPets.count > 1 {
                                            whoFedBlaiseViewModel.selectedPetPicker = true
                                        }
                                    }
                            }
                        }
                    }
                    HStack() {
                        Label("", systemImage: "photo")
                            .onTapGesture {
                                whoFedBlaiseViewModel.selectedPetPhoto = true
                            }
                        Spacer()
                        VStack() {
                            Text("@"+whoFedBlaiseViewModel.account)
                            if !(whoFedBlaiseViewModel.account==whoFedBlaiseViewModel.feeder)   {
                                Label(whoFedBlaiseViewModel.feeder, systemImage: "person")
                            }
                        }
                        Spacer()
                    }
                }
                .font(.title2)
                
                Rectangle()
                    .frame(maxHeight: .infinity)
                    .opacity(0.001)
                
                if Int(whoFedBlaiseViewModel.recordNumber)<=1 || whoFedBlaiseViewModel.role>=Role.ROLE_LEVEL_CHILD {
                    if whoFedBlaiseViewModel.feedingRecords.count>=1 {
                        RecordView(whoFedBlaiseViewModel: whoFedBlaiseViewModel, feedingRecord: whoFedBlaiseViewModel.feedingRecords[0])
                    }
                } else {
                    List {
                        ForEach(whoFedBlaiseViewModel.feedingRecords, id: \.timestamp, content: { feedingRecord in
                            RecordView(whoFedBlaiseViewModel: whoFedBlaiseViewModel, feedingRecord: feedingRecord)
                        })
                    }
                    .listStyle(.plain)
                    .opacity(0.5)
                }
                
                HStack {
                    Label("", systemImage: "battery.100percent")
                        .onTapGesture {
                            whoFedBlaiseViewModel.addFeedingRecort(portion: 1)
                        }
                        .foregroundColor(whoFedBlaiseViewModel.feedingColor)
                        .scaleEffect(2.0)
                    
                    Label("", systemImage: "battery.50percent")
                        .onTapGesture {
                            whoFedBlaiseViewModel.addFeedingRecort(portion: 0.5)
                        }
                        .foregroundColor(whoFedBlaiseViewModel.feedingColor)
                        .scaleEffect(2.0)
                }
                
                Rectangle()
                    .frame(maxHeight: 10)
                    .opacity(0.001)
            }
        }
}


