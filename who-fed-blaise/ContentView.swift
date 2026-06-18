//
//  ContentView.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 12.05.22.
//

import SwiftUI

struct ContentView: View {

    let logger = Logger(category: "ContentView")

    @ObservedObject var whoFedBlaiseViewModel: WhoFedBlaiseViewModel

    var body: some View {
        ZStack {
            PetListTabView(whoFedBlaiseViewModel: whoFedBlaiseViewModel)
        }
        .foregroundColor(Defaults.COLORS[whoFedBlaiseViewModel.foregroundColor])
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(whoFedBlaiseViewModel: WhoFedBlaiseViewModel())
        }
    }
}
