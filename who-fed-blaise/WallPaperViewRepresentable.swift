//
//  WallPaperViewRepresentable.swift
//  who-fed-blaise
//
//  Created by gude on 28.11.25.
//

import SwiftUI
//import UIKit
import PhotosUI

struct WallPaperViewControllerRepresentable: UIViewControllerRepresentable {
    
    //typealias UIViewControllerType = PHPickerViewController

    let logger = Logger(Logger.PARAMETER_DEBUG, category: "WallPaperRepresentable")
    
    @Binding var showPicker: Bool
    @Binding var imagePicked: Bool
    @Binding var pickedImage: UIImage?

    //let onDismiss: () -> Void
    private let picker: PHPickerViewController
    
    init(showPicker: Binding<Bool>, imagePicked: Binding<Bool>, pickedImage: Binding<UIImage?>) {
        logger.debug("Make PHPickerViewController")
        var config = PHPickerConfiguration()
        config.filter = PHPickerFilter.all(of: [.images])
        config.preferredAssetRepresentationMode = .current
        config.selection = .default
        config.selectionLimit = 1
        //config.preselectedAssetIdentifiers =
        self.picker = PHPickerViewController(configuration: config)
        self._showPicker = showPicker
        self._imagePicked = imagePicked
        self._pickedImage = pickedImage
        //self.onDismiss = onDismiss
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<WallPaperViewControllerRepresentable>) -> PHPickerViewController {
        picker.delegate = context.coordinator
        return picker
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(control: self)
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let control: WallPaperViewControllerRepresentable
        
        init(control: WallPaperViewControllerRepresentable) {
            self.control = control
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if results.isEmpty {
                picker.dismiss(animated: true, completion: nil)
                return
            }
            
            let dispatchSemaphore = DispatchSemaphore(value: 0)
            var pickedImage: UIImage? = nil
            for result in results.enumerated() {
                if !result.element.itemProvider.canLoadObject(ofClass: UIImage.self) { continue }
                result.element.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let image: UIImage = image as? UIImage {
                        pickedImage = image
                    }
                    dispatchSemaphore.signal()
                }
                dispatchSemaphore.wait()
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.control.pickedImage = pickedImage
                self?.control.showPicker = false
                self?.control.imagePicked = true
                picker.dismiss(animated: true) {
                    //self?.control.onDismiss()
                }
            }
        }
    }
}


