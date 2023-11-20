//
//  ContentView.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 02.05.23.
//

import SwiftUI

struct SettingView: View {

    @Binding var petName: String
    @Binding var url: String
    @Binding var recordNumber: Int
    
    var body: some View {
        
        VStack {
                    
            //Text(feedingViewModel.getPetName())
            //    .font(.largeTitle)
            TextField("Pet Name", text: $petName)
                .font(.largeTitle)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(lineWidth: 1)
                )
                
            TextField("URL", text: $url)
                .font(.largeTitle)
            
            Text(String(recordNumber))
                .font(.largeTitle)

        }
    }
}
