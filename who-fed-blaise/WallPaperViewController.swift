//
//  WallPaperView.swift
//  who-fed-blaise
//
//  Created by Guillaume on 13.06.25.
//


import SwiftUI
import PhotosUI
/*
 struct WallPaperViewController: UIViewControllerRepresentable {
 
 //@ObservedObject var feedingViewModel: FeedingViewModel
 @Binding var wallPaperUIImage: UIImage?
 static let logger = Logger(Logger.PARAMETER_DEBUG, category: "WallPaperViewController")
 
 typealias UIViewControllerType = PHPickerViewController
 
 func makeCoordinator() -> Coordinator {
 Coordinator(parent: self)
 }
 
 class Coordinator: NSObject, PHPickerViewControllerDelegate, UINavigationControllerDelegate {
 
 var parent: WallPaperViewController?
 
 func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
 
 guard let image = info[.editedImage] as? UIImage else { return }
 
 let imageName = UUID().uuidString
 WallPaperViewController.logger.debug("imageName \(imageName)")
 let imagePath = Parameters.getWallPaperPath()
 WallPaperViewController.logger.debug("imagePath \(imagePath)")
 
 if let jpegData = image.jpegData(compressionQuality: 1.0) {
 WallPaperViewController.logger.debug("Write jpeg to imagePath \(imagePath)")
 try? jpegData.write(to: imagePath)
 self.parent?.wallPaperUIImage = image
 Parameters.setCustomizeWallPaper(false)
 }
 
 picker.dismiss(animated: true)
 }
 
 init(parent: WallPaperViewController) {
 self.parent = parent
 }
 }
 /*
  class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate { //PHPickerViewControllerDelegate {
  
  var parent: WallPaperViewController?
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
  
  guard let image = info[.editedImage] as? UIImage else { return }
  
  let imageName = UUID().uuidString
  WallPaperViewController.logger.debug("imageName \(imageName)")
  let imagePath = Parameters.getWallPaperPath()
  WallPaperViewController.logger.debug("imagePath \(imagePath)")
  
  if let jpegData = image.jpegData(compressionQuality: 1.0) {
  WallPaperViewController.logger.debug("Write jpeg to imagePath \(imagePath)")
  try? jpegData.write(to: imagePath)
  self.parent?.wallPaperUIImage = image
  Parameters.setCustomizeWallPaper(false)
  }
  
  picker.dismiss(animated: true)
  }
  
  init(parent: WallPaperViewController) {
  self.parent = parent
  }
  }
  
  func makeUIViewController(context: Context) -> UIImagePickerController {
  let picker = UIImagePickerController()
  picker.allowsEditing = false
  picker.sourceType = .photoLibrary
  picker.delegate = context.coordinator
  return picker
  }
  
  func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
  */
 
 }
 */
