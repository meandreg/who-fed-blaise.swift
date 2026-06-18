//
//  ContentView.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 02.05.23.
//

import SwiftUI

struct SettingView: View {
    
    @ObservedObject var whoFedBlaiseViewModel: WhoFedBlaiseViewModel
    
    //var feederAccounts: [String] = ["clairedufour@free.fr","guillaume@meandre.eu","blaiselechat@gmail.com"]
    //private let logLevels = [Logger.PARAMETER_DEFAULT,Logger.PARAMETER_ERROR,Logger.PARAMETER_WARNING,Logger.PARAMETER_INFO,Logger.PARAMETER_DEBUG]
    
    var body: some View {
        
        VStack {
            HStack {
                Label("", systemImage: "pawprint")
                    .onTapGesture {
                        WhoFedBlaiseDefaults.save(whoFedBlaiseViewModel)
                        whoFedBlaiseViewModel.selectedPetConfig = false
                    }
                if !whoFedBlaiseViewModel.feederPets.isEmpty {
                    Spacer()
                    Label("", systemImage: "plus.square.on.square")
                        .onTapGesture {
                            whoFedBlaiseViewModel.addFeederPet()
                        }
                    if whoFedBlaiseViewModel.selectedPets.isMultiple {
                        Label("", systemImage: "pip.remove")
                            .onTapGesture {
                                whoFedBlaiseViewModel.removeCurrentPet()
                                whoFedBlaiseViewModel.selectedPetConfig = false
                            }
                    }
                }
            }
            
            List {
                HStack {
                    LabeledTextField(label: "Hostname", value: $whoFedBlaiseViewModel.hostname)
                        .background(Defaults.COLORS[whoFedBlaiseViewModel.backgroundColor])
                    LabeledTextField(label: "port", value: $whoFedBlaiseViewModel.port)
                }
                
                LabeledTextField(label: "feeder", value: $whoFedBlaiseViewModel.feeder)
                    .onAppear() {
                        whoFedBlaiseViewModel.getFeederPets()
                    }
                    .onSubmit {
                        whoFedBlaiseViewModel.getFeederPets()
                    }

                /*FeederPasswordTextFields(feeder: $whoFedBlaiseViewModel.feeder, password: $whoFedBlaiseViewModel.password)
                    .onAppear() {
                        whoFedBlaiseViewModel.getFeederPets()
                    }
                    .onSubmit {
                        whoFedBlaiseViewModel.getFeederPets()
                    }
                    .onChange(of: whoFedBlaiseViewModel.feeder) { newValue in
                        whoFedBlaiseViewModel.getFeederPets()
                    }
                */
                
                Picker(LocalizedStringKey(Labels.PETNAME),
                    selection: $whoFedBlaiseViewModel.id,
                    content: {
                        ForEach(whoFedBlaiseViewModel.feederPets.pets) {pet in
                            if whoFedBlaiseViewModel.selectedPets.exists(pet.id) {
                                Label(pet.name+"\n(@) "+pet.account, systemImage: "checkmark")
                                    .tag(pet.id)
                                    .font(.callout)
                            } else {
                                Text(pet.name+"\n(@) "+pet.account)
                                    .tag(pet.id)
                            }
                        }
                    }
                )
                .pickerStyle(.menu)
                .onChange(of: whoFedBlaiseViewModel.id, perform: { newId in
                    if !whoFedBlaiseViewModel.selectedPets.exists(newId) {
                        whoFedBlaiseViewModel.swapTo(newId)
                    }
                })
                
                SliderText(min: 1, max: 10,
                           label1: LocalizedStringKey(Labels.RECORDNUMBER),
                           label2: "",
                           variable: $whoFedBlaiseViewModel.recordNumber,
                           modulo:  1
                )
                
                SliderText(min: 60, max: 24*60,
                           label1: LocalizedStringKey(Labels.FEEDINGNEXT),
                           label2: LocalizedStringKey("hours(s)"),
                           variable: $whoFedBlaiseViewModel.feedingNext,
                           modulo:  60
                )
                
                SliderText(min: 1, max: 60,
                           label1: LocalizedStringKey(Labels.NOTIFYBEFORE),
                           label2: LocalizedStringKey("minute(s)"),
                           variable: $whoFedBlaiseViewModel.notifyBefore,
                           modulo:  1
                )
                
                SliderText(min: 1, max: 60,
                           label1: LocalizedStringKey(Labels.NOTIFEVERY),
                           label2: LocalizedStringKey("minute(s)"),
                           variable: $whoFedBlaiseViewModel.notifyEvery,
                           modulo:  1
                )
                
                Picker(LocalizedStringKey(Labels.LOGLEVEL),
                    selection: $whoFedBlaiseViewModel.logLevel,
                    content: {
                        ForEach(Logger.LABELS, id: \.self) {
                                Text($0)
                                .tag(Logger.getLevel($0))
                            }
                        }
                )
                .pickerStyle(.menu)
                .onChange(of: whoFedBlaiseViewModel.logLevel) { newLogLevel in
                    whoFedBlaiseViewModel.setLogLevel(newLogLevel)
                }
            }
        }
        //.background(Defaults.COLORS[whoFedBlaiseViewModel.backgroundColor])
        .listStyle(.plain)
        .opacity(0.8)
        //.backgroundColor(Defaults.COLORS[whoFedBlaiseViewModel.backgroundColor])
        /*.listStyle(.plain)
        .font(.title3)
        .onAppear(perform: {
            //whoFedBlaiseViewModel.savePet()
        })*/
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
            Text(LocalizedStringKey(label))
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
            Text(LocalizedStringKey(Labels.PASSWORD))
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            SecureField(Labels.PASSWORD, text: $password)
                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                .border(.gray)
        }
    }
}
