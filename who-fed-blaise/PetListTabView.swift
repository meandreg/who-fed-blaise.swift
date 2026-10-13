//
//  PetListTabView.swift
//  who-fed-blaise
//
//  Created by gude on 09.12.25.
//

import SwiftUI

struct PetListTabView: View {
    
    @ObservedObject var whoFedBlaiseViewModel: WhoFedBlaiseViewModel

    //@State private var currentPet: UUID = feedingViewModel.currentPet
    
    let logger = Logger(category: "PetListTabView")
    
    var body: some View {
        ZStack {
            if whoFedBlaiseViewModel.selectedPetConfig == true {
                SettingView(whoFedBlaiseViewModel: whoFedBlaiseViewModel)
            } else if whoFedBlaiseViewModel.selectedPetPhoto == true {
                if #available(iOS 19, *) {
                    WallPaperPhotoPickerView(wfb: whoFedBlaiseViewModel)
                } else {
                    WallPaperPHPickerView(wfb: whoFedBlaiseViewModel)
                }
            } else {
                FeedingView(wfb: whoFedBlaiseViewModel)
                    .onAppear(perform: {
                        NotificationManager.notificatioManager.requestNotification()
                        whoFedBlaiseViewModel.getFeedingRecords()
                    })
            }
        }
        .background(
            FeedingViewBackgroundView(whoFedBlaiseViewModel: whoFedBlaiseViewModel)
        )
        /*.onAppear(perform: {
            whoFedBlaiseViewModel.getUpdatedPet()
        })*/
    }
}

