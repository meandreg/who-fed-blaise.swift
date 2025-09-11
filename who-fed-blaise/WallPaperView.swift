//
//  WallPaperView.swift
//  who-fed-blaise
//
//  Created by Guillaume on 13.06.25.
//

import SwiftUI

struct WallPaperView: View {
    
    @ObservedObject var feedingViewModel: FeedingViewModel
    //var image: Image
    //@State var inputImage: UIImage?
    //@State var isPresented: Bool = true
    let logger = Logger(Logger.PARAMETER_INFO, category: "WallPaperView")
 
    var body: some View {
        VStack {
            feedingViewModel.wallPaperImage.resizable()
            /*Button("Load Image") {
                image = Image("image")
            }*/
        }
        /*.sheet(isPresented: $isPresented) {
            WallPaperViewController(image: $inputImage)
        }
        .onChange(of: inputImage) { _ in loadImage()}*/
    }
    
    /*func loadImage() {
        logger.debug(".loadImage()")
        guard let inputImage = inputImage else { return }
        logger.debug(".loadImage() : got imputImage")
        image = Image(uiImage: inputImage)
        logger.debug(".loadImage() : set image")
    }*/
}
