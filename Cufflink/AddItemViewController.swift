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
    
    var imageButtonTagToPass = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addImageOneButton.layer.borderWidth = 1
        addImageTwoButton.layer.borderWidth = 1
        addImageThreeButton.layer.borderWidth = 1
        doneEditingButton.layer.cornerRadius = 20
        doneEditingButton.clipsToBounds = true
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
        case 2:
            addImageTwoButton.setTitle("", for: .normal)
            addImageTwoButton.setBackgroundImage(chooseImageViewController.chosenImage2, for: .normal)
        case 3:
            addImageThreeButton.setTitle("", for: .normal)
            addImageThreeButton.setBackgroundImage(chooseImageViewController.chosenImage3, for: .normal)
        default:
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
    
    @IBAction func doneAddingButtonTapped(_ sender: UIButton) {
        //Add verification to this...
        if itemTitleTextField.text == "" || itemPriceTextField.text == "" || itemDescriptionTextView.text == ""{
            showAlertMessage(messageHeader: "Missing Required Fields!", messageBody: "Please enter all required fields for this item")
            return
        }
        
        if addImageOneButton.backgroundImage(for: .normal) == nil && addImageTwoButton.backgroundImage(for: .normal) == nil && addImageThreeButton.backgroundImage(for: .normal) == nil{
            showAlertMessage(messageHeader: "Missing Images!", messageBody: "Please add at least one image to your item")
            return
        }
        
        var unitForPrice = priceUnitSegmentControl.selectedSegmentIndex == 0 ? "perHour" : "perDay"
        
        
        let postString = [
            "title": itemTitleTextField.text!,
            "price": itemPriceTextField.text!,
            "unitForPrice": unitForPrice,
            "description": itemDescriptionTextView.text
        ] as [String: String]
        
        
        self.appDelegate.requestUrl("/items", nil) { (body, response) in
            let array = body as! [NSDictionary]
            let allItems = array.map { Item($0) }
        
        }
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
