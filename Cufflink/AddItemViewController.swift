//
//  AddItemViewController.swift
//  Cufflink
//
//  Created by Zuri Wong on 4/18/18.
//  Copyright © 2018 Zuri Wong. All rights reserved.
//

import UIKit

class AddItemViewController: UIViewController {

    // Obtain the object reference to the App Delegate object
    var appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet var itemTitleTextField: UITextField!
    @IBOutlet var itemPriceTextField: UITextField!
    @IBOutlet var addImageOneButton: UIButton!
    @IBOutlet var addImageTwoButton: UIButton!
    @IBOutlet var addImageThreeButton: UIButton!
    @IBOutlet var doneEditingButton: UIButton!
    @IBOutlet var itemDescriptionTextView: UITextView!
    @IBOutlet var priceUnitSegmentControl: UISegmentedControl!
    @IBOutlet var deleteImageTwoButton: UIButton!
    @IBOutlet var deleteImageThreeButton: UIButton!
    
    var chosenImageOnePassed: UIImage?
    var chosenImageTwoPassed: UIImage?
    var chosenImageThreePassed: UIImage?
    
    var imageButtonTagToPass = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addImageOneButton.layer.borderWidth = 1
        addImageTwoButton.layer.borderWidth = 1
        addImageThreeButton.layer.borderWidth = 1
        doneEditingButton.layer.cornerRadius = 20
        doneEditingButton.clipsToBounds = true
        
        
        //Making Delete Image Buttons circular
        deleteImageTwoButton.layer.borderWidth = 1
        deleteImageTwoButton.layer.masksToBounds = false
        deleteImageTwoButton.layer.borderColor = UIColor.white.cgColor
        deleteImageTwoButton.layer.cornerRadius = deleteImageTwoButton.frame.height/2
        deleteImageTwoButton.clipsToBounds = true
        
        deleteImageThreeButton.layer.borderWidth = 1
        deleteImageThreeButton.layer.masksToBounds = false
        deleteImageThreeButton.layer.borderColor = UIColor.white.cgColor
        deleteImageThreeButton.layer.cornerRadius = deleteImageThreeButton.frame.height/2
        deleteImageThreeButton.clipsToBounds = true
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func imageButtonTapped(_ sender: UIButton) {
        imageButtonTagToPass = sender.tag
        performSegue(withIdentifier: "Choose Image", sender: self)
    }
    
    /*
     ---------------------------
     MARK: - Unwind Segue Method
     ---------------------------
     */
    @IBAction func unwindToAddItemViewController(segue : UIStoryboardSegue) {
        if segue.identifier !=  "ChooseImage-Done"  {
            return
        }
    
        // Obtain the object reference of the source view controller
        let chooseImageViewController: ChooseImageViewController = segue.source as! ChooseImageViewController
        switch imageButtonTagToPass {
        case 1:
            addImageOneButton.setTitle("", for: .normal)
            addImageOneButton.setBackgroundImage(chooseImageViewController.chosenImage1, for: .normal)
            chosenImageOnePassed = chooseImageViewController.chosenImage1
        case 2:
            addImageTwoButton.setTitle("", for: .normal)
            addImageTwoButton.setBackgroundImage(chooseImageViewController.chosenImage2, for: .normal)
            chosenImageTwoPassed = chooseImageViewController.chosenImage2
        case 3:
            addImageThreeButton.setTitle("", for: .normal)
            addImageThreeButton.setBackgroundImage(chooseImageViewController.chosenImage3, for: .normal)
            chosenImageThreePassed = chooseImageViewController.chosenImage3
        default:
            return
        }
        
        
        
    }
    
    @IBAction func deleteImageButtonTapped(_ sender: UIButton) {
        if sender.tag == 2{
            if chosenImageTwoPassed != nil{
                chosenImageTwoPassed = nil
                addImageTwoButton.setBackgroundImage(nil, for: .normal)
                addImageTwoButton.setTitle("Add Image", for: .normal)
            }
        }else if sender.tag == 3{
            if chosenImageThreePassed != nil{
                chosenImageThreePassed = nil
                addImageThreeButton.setBackgroundImage(nil, for: .normal)
                addImageThreeButton.setTitle("Add Image", for: .normal)
            }
        }else{
            return
        }
    }
    
    
    /*
     -------------------------
     MARK: - Prepare For Segue
     -------------------------
     */
    
    // This method is called by the system whenever you invoke the method performSegueWithIdentifier:sender:
    // You never call this method. It is invoked by the system.
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if segue.identifier == "Choose Image" {
            
            // Obtain the object reference of the source view controller
            let chooseImageViewController: ChooseImageViewController = segue.destination as! ChooseImageViewController
            
            // Pass the data object to the downstream view controller object
            chooseImageViewController.imageButtonTagPassed = imageButtonTagToPass
            
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //Add verification to this...
        if itemTitleTextField.text == "" || itemPriceTextField.text == "" || itemDescriptionTextView.text == ""{
            showAlertMessage(messageHeader: "Missing Required Fields!", messageBody: "Please enter all required fields for this item")
            return false
        }
        
        if addImageOneButton.backgroundImage(for: .normal) == nil && addImageTwoButton.backgroundImage(for: .normal) == nil && addImageThreeButton.backgroundImage(for: .normal) == nil{
            showAlertMessage(messageHeader: "Missing Images!", messageBody: "Please add at least one image to your item")
            return false
        }
        
        
        return true
    }
    

        
        
        
    
    
    /*
     ------------------------
     MARK: - IBAction Methods
     ------------------------
     */
    @IBAction func keyboardDone(_ sender: UITextField) {
        
        // When the Text Field resigns as first responder, the keyboard is automatically removed.
        sender.resignFirstResponder()
    }
    
    @IBAction func backgroundTouch(_ sender: UIControl) {
        /*
         "This method looks at the current view and its subview hierarchy for the text field that is
         currently the first responder. If it finds one, it asks that text field to resign as first responder.
         If the force parameter is set to true, the text field is never even asked; it is forced to resign." [Apple]
         
         When the Text Field resigns as first responder, the keyboard is automatically removed.
         */
        view.endEditing(true)
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
