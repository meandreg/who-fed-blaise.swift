//
//  ContentView.swift
//  who-fed-blaise
//
//  Created by Guillaume Devillers on 12.05.22.
//

import SwiftUI

struct FeedingViewClaire: View {
    
    @ObservedObject var feedingViewModel: FeedingViewModel
    /*
    @State var wallPaperImage: Image = Parameters.getWallPaperImage()
    @State var wallPaperUIImage: UIImage? = Parameters.getWallPaperUIImage()
    @State var customizeWallPaper: Bool = Parameters.getCustomizeWallPaper()
    */
    var body: some View {
        
        VStack {
            VStack {
                HStack {
                    TextField("Pet Name", text: $feedingViewModel.petName)
                        .padding()
                    /*.overlay(
                     RoundedRectangle(cornerRadius: 0)
                     .stroke(lineWidth: 1)
                     )*/
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .onSubmit {
                            feedingViewModel.saveSetting()
                            feedingViewModel.get()
                        }
                    
                    Label("", systemImage: "arrow.clockwise")
                        .onTapGesture {
                            feedingViewModel.get()
                        }
                }
                .font(.largeTitle)
                .frame(alignment: .top)
            }
            //.frame(maxHeight: .infinity)
            
            Rectangle()
                .frame(maxHeight: .infinity)
                .opacity(0.0)
                /*.onTapGesture(perform: {
                    feedingViewModel.customizeWallPaper.toggle()
                })*/
            
            if(feedingViewModel.getFeedingRecords().count>0) {
                RecordView(feedingViewModel: feedingViewModel, feedingRecord: feedingViewModel.getFeedingRecords()[0])
            }
            
            HStack {
                Text(LocalizedStringKey("full-portion"))
                    .onTapGesture {
                        feedingViewModel.add(1)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(lineWidth: 4)
                    )
                
                Text(LocalizedStringKey("half-portion"))
                    .onTapGesture {
                        feedingViewModel.add(0.5)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(lineWidth: 4)
                    )
            }
            .font(.title3)
            
        }
        /*
        .background(
            feedingViewModel.wallPaperImage
                .resizable()
        )
        .sheet(isPresented: $feedingViewModel.customizeWallPaper) {
            WallPaperViewController(wallPaperUIImage: $feedingViewModel.wallPaperUIImage)
        }
        .onChange(of: feedingViewModel.wallPaperUIImage) { _ in loadImage() }
        */
    }
    /*
    func loadImage() {
        guard let uiImage = feedingViewModel.wallPaperUIImage else { return }
        feedingViewModel.wallPaperImage = Image(uiImage: uiImage)
    }
    */
}



