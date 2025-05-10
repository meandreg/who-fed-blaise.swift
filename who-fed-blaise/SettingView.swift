//
//  ContentView.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 02.05.23.
//

import SwiftUI

struct SettingView: View {
    
    @ObservedObject var feedingViewModel: FeedingViewModel
    
    private let logLevels = [Logger.PARAMETER_DEFAULT,Logger.PARAMETER_ERROR,Logger.PARAMETER_WARNING,Logger.PARAMETER_INFO,Logger.PARAMETER_DEBUG]
    
    var body: some View {
        
        List {
            LabeledTextField(label: Labels.ACCOUNT, value: $feedingViewModel.account)
            FeederPasswordTextFields(feeder: $feedingViewModel.feeder, password: $feedingViewModel.password)
            LabeledTextField(label: Labels.URL.uppercased(), value: $feedingViewModel.url)
            
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
            
            Picker("Log Level",
                   selection: $feedingViewModel.logLevel,
                   content: {
                ForEach(logLevels, id: \.self) {Text($0)}
            })
            .pickerStyle(.menu)
            .onChange(of: feedingViewModel.logLevel) { newLogLevel in
                feedingViewModel.logger.setLevel(newLogLevel)
            }
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
        VStack (alignment: .center, spacing: 0) {
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

struct LabeledTextField :View{
    
    let label: String
    @Binding var value: String
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            Text("**\(label)**")
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            TextField(label, text: $value)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                .border(.gray)
        }
    }
}

struct FeederPasswordTextFields :View {
    
    @Binding var feeder: String
    @Binding var password: String
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0){
            LabeledTextField(label: Labels.FEEDER, value: $feeder)
            Text("**\(Labels.PASSWORD)**")
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            SecureField(Labels.PASSWORD, text: $password)
                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                .border(.gray)
        }
    }
}
