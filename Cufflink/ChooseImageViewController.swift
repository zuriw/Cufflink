//
//  ChooseImageViewController.swift
//  Cufflink
//
//  Created by Zuri Wong on 4/28/18.
//  Copyright © 2018 Zuri Wong. All rights reserved.
//

import UIKit
import AVFoundation

class ChooseImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Obtain the object reference to the App Delegate object
    var appDelegate = UIApplication.shared.delegate as! AppDelegate

    
    var chosenImage1 = UIImage()
    var chosenImage2 = UIImage()
    var chosenImage3 = UIImage()
    
    @IBOutlet var imageView: UIImageView!
    // User's authorization is required to access the camera
    var cameraUseAuthorizedByUser = false
    let picker = UIImagePickerController()
    
    var imageButtonTagPassed = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        askUserPermissionToUseCamera()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func takePhotoButtonTapped(_ sender: UIButton) {
        /*
         The user may have changed the permission to access camera in Settings.
         Therefore, we need to check the authorization status to access the camera.
         */
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            if cameraUseAuthorizedByUser{
                
                picker.allowsEditing = false
                picker.sourceType = UIImagePickerControllerSourceType.camera
                picker.cameraCaptureMode = .photo
                picker.modalPresentationStyle = .fullScreen
                present(picker,animated: true,completion: nil)
            }else{
                showAlertMessage(messageHeader: "Permission Required!", messageBody: "In the Settings app, please allow Cufflink to access Camera")
                return
            }
        }else{
            showAlertMessage(messageHeader: "No Camera Found", messageBody: "Sorry, this feature is not available at your device")
            return
        }
        
        
    }
    
    @IBAction func photoLibraryButtonTapped(_ sender: UIButton) {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        //picker.modalPresentationStyle = .popover
        present(picker, animated: true, completion: nil)
    }
    
    /*
     -----------------------------------------------
     MARK: - Ask User's Permission to Use the Camera
     -----------------------------------------------
     */
    func askUserPermissionToUseCamera() {
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {
            
            /* "The response parameter is a block whose sole parameter [named here as permissionGranted]
             indicates whether the user granted or denied permission to record." [Apple]
             */
            permissionGranted in
            
            if permissionGranted {
                
                self.cameraUseAuthorizedByUser = true
                
            } else {
                self.cameraUseAuthorizedByUser = false
            }
        })
    }
    
    //MARK: - Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        switch imageButtonTagPassed {
        case 1:
            chosenImage1 = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            self.appDelegate.upload(image: chosenImage1) {(returnURL) in
                
                print("RETURNED URL: \(returnURL)")
            }
            
            imageView.image = chosenImage1
        case 2:
            chosenImage2 = info[UIImagePickerControllerOriginalImage] as! UIImage
            imageView.image = chosenImage2
        case 3:
            chosenImage3 = info[UIImagePickerControllerOriginalImage] as! UIImage
            imageView.image = chosenImage3
        default:
            return
        }
        imageView.contentMode = .scaleAspectFit
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    

 
        
    
    
    /*
     -----------------------------
     MARK: - Display Alert Message
     -----------------------------
     */
    func showAlertMessage(messageHeader header: String, messageBody body: String) {
        
        /*
         Create a UIAlertController object; dress it up with title, message, and preferred style;
         and store its object reference into local constant alertController
         */
        let alertController = UIAlertController(title: header, message: body, preferredStyle: UIAlertControllerStyle.alert)
        
        // Create a UIAlertAction object and add it to the alert controller
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }

}
