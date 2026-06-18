//
//  ContentView.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 12.05.22.
//

import SwiftUI

struct FeedingView: View {
    
    let logger = Logger(category: "FeedingView")

    @ObservedObject var whoFedBlaiseViewModel: WhoFedBlaiseViewModel
    
    @State private var offset = CGSize.zero
    
    var body: some View {
            VStack {
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
                                    whoFedBlaiseViewModel.fontsize(increase: true)
                                }).exclusively(before: TapGesture(count: 1).onEnded({
                                    whoFedBlaiseViewModel.fontsize(increase: false)
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
                        if whoFedBlaiseViewModel.selectedPets.isMultiple() {
                            Label("", systemImage: "checklist")
                            .onTapGesture {
                                whoFedBlaiseViewModel.selectedPetPicker = true
                            }
                        }
                    }
                }
                //.font(.title2)
                
                //Rectangle()
                //    .frame(maxHeight: .infinity)
                //    .opacity(0.001)
                HStack {
                    /*Spacer()
                    Label("", systemImage: "textformat.size")
                        .gesture(
                            TapGesture(count: 2).onEnded({
                                whoFedBlaiseViewModel.fontsize(increase: true)
                            }).exclusively(before: TapGesture(count: 1).onEnded({
                                whoFedBlaiseViewModel.fontsize(increase: false)
                            }))
                        )
                        .scaleEffect(1.5)*/
                    Spacer()
                    Label("", systemImage: "battery.100percent")
                        .onTapGesture {
                            whoFedBlaiseViewModel.addFeedingRecord(portion: 1)
                        }
                        .foregroundColor(whoFedBlaiseViewModel.feedingColor)
                        .scaleEffect(2.0)
                    Spacer()
                    Label("", systemImage: "battery.50percent")
                        .onTapGesture {
                            whoFedBlaiseViewModel.addFeedingRecord(portion: 0.5)
                        }
                        .foregroundColor(whoFedBlaiseViewModel.feedingColor)
                        .scaleEffect(2.0)
                    Spacer()
                    if (Int(whoFedBlaiseViewModel.recordNumber)<=1 || whoFedBlaiseViewModel.role<Role.ROLE_LEVEL_USER) && whoFedBlaiseViewModel.feedingRecords.count==1 {
                        if whoFedBlaiseViewModel.feedingRecords[0].alias==whoFedBlaiseViewModel.alias {
                            Label("", systemImage: "trash")
                                .onTapGesture {
                                    whoFedBlaiseViewModel.delFeedingRecord(feedingRecord: whoFedBlaiseViewModel.feedingRecords[0])
                                }
                                .foregroundColor(whoFedBlaiseViewModel.feedingColor)
                                .scaleEffect(1.5)
                        }
                        Spacer()
                    }
                }
                
                /*Spacer()
                
                if Int(whoFedBlaiseViewModel.recordNumber)<=1 || whoFedBlaiseViewModel.role<Role.ROLE_LEVEL_USER || whoFedBlaiseViewModel.feedingRecords.count<=1 {
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
                */
                
                
                //Rectangle()
                //    .frame(maxHeight: 10)
                //    .opacity(0.001)
            }
        }
}


