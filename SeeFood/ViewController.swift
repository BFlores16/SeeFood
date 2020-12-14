//
//  ViewController.swift
//  SeeFood
//
//  Created by Brando Flores on 12/12/20.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        // Choose how to use the camera button
        imagePicker.sourceType = .camera
        //imagePicker.sourceType = .photoLibrary
        
        
        imagePicker.allowsEditing = false
    }
    
    // Tell view controller that user has picked an image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            // Convert to Core Image Image (CII)
            // Allows us to user COREML to get an interpretation from it
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert CIImage")
            }
            print("second")
            detect(image: ciimage)
        }

        imagePicker.dismiss(animated: true, completion: nil)
        
        print("third")
    }
    
    private func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading COREML model failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            if let firstResult = results.first {
                let confidence = firstResult.confidence * 100
                let confidenceString = String(format: "%.2f", confidence)
                self.navigationItem.title = ("\(firstResult.identifier): %\(confidenceString)")
                
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try! handler.perform([request])
        }
        catch {
            print(error.localizedDescription)
        }
        
    }

    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        print("first")
        present(imagePicker, animated: true, completion: nil)
        
    }
    
}

