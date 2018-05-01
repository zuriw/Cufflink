//
//  SettingsViewController.swift
//  Cufflink
//
//  Created by Zuri Wong on 4/30/18.
//  Copyright © 2018 Zuri Wong. All rights reserved.
//

import UIKit
import CoreLocation

class SettingsViewController: UIViewController {
    
    // Obtain the object reference to the App Delegate object
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet var profilePictureButton: UIButton!
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var cityTextField: UITextField!
    @IBOutlet var stateTextField: UITextField!
    @IBOutlet var phoneTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentUser = appDelegate.currentUser
        
        firstNameTextField.text = currentUser.firstName
        lastNameTextField.text = currentUser.lastName
        var addr = currentUser.location.split(separator: ",")
        let city = addr[addr.count - 2]
        let state = addr[addr.count - 1]
        var address = ""
        for index in 0...addr.count - 3{
            address = address + addr[index]
        }
        addressTextField.text = address
        cityTextField.text = String(city)
        stateTextField.text = String(state)
        self.phoneTextField.text = currentUser.phone
        
        
        if currentUser.profile != ""{
            profilePictureButton.setTitle("", for: .normal)
            let profileStr = currentUser.profile
            let url = URL(string: profileStr)!
            let profileData = try? Data(contentsOf: url)
            profilePictureButton.setImage(UIImage(data: profileData!)!, for: .normal)
            profilePictureButton.imageView?.contentMode = UIViewContentMode.scaleAspectFill
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func profilePictureButtonTapped(_ sender: UIButton) {
         performSegue(withIdentifier: "Choose Image", sender: self)
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
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //Add verification to this...
        if firstNameTextField.text == "" || lastNameTextField.text == "" || addressTextField.text == "" || cityTextField.text == "" || stateTextField.text == "" || phoneTextField.text == ""{
            showAlertMessage(messageHeader: "Missing Required Fields!", messageBody: "Please enter all required fields for this item")
            return false
        }
        
        
        return true
    }

    /*
     -------------------------
     MARK: - Prepare For Segue
     -------------------------
     */
    
    // This method is called by the system whenever you invoke the method performSegueWithIdentifier:sender:
    // You never call this method. It is invoked by the system.
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
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
