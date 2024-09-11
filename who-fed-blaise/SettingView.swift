//
//  ContentView.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 02.05.23.
//

import SwiftUI

struct SettingView: View {
    
    @ObservedObject var feedingViewModel: FeedingViewModel
    
    var body: some View {
        
        List {
            TextField("Feeder", text: $feedingViewModel.feeder)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(lineWidth: 1)
                )
                .autocorrectionDisabled()
            
            TextField("URL", text: $feedingViewModel.url)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(lineWidth: 1)
                )
                .autocapitalization(.none)
                .autocorrectionDisabled()
            
            SliderText(min: 0, max: 10,
                       label1: "record-number",
                       label2: "",
                       variable: $feedingViewModel.recordNumber,
                       modulo:  1
            )
            
            SliderText(min: 60, max: 24*60,
                label1: "next-feeding-in",
                label2: "hours(s)",
                variable: $feedingViewModel.feedingNext,
                modulo:  60
            )
            
            SliderText(min: 0, max: 60,
                label1: "notification-start",
                label2: "minute(s)",
                variable: $feedingViewModel.notificationBefore,
                       modulo:  1
            )
            
            SliderText(min: 1, max: 60,
                label1: "notification-frequency",
                label2: "minute(s)",
                variable: $feedingViewModel.notificationEvery,
                       modulo:  1
            )
        }
        .onDisappear() {
            feedingViewModel.saveSetting()
        }
        .listStyle(.plain)
        .font(.title3)

    }
}


struct SliderText: View {

    let min: Float
    let max: Float
    let label1: LocalizedStringKey
    let label2: LocalizedStringKey
    @Binding var variable: Float
    let modulo: Float
        
    var body: some View {
        VStack {
            Slider(
                value: $variable,
                in: min...max
            )
            HStack {
                Text(label1)
                Text("\(Int(variable/modulo))")
                Text(label2)
            }
        }
    }
}
