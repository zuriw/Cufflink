//
//  ChangePasswordViewController.swift
//  Cufflink
//
//  Created by Zuri Wong on 4/30/18.
//  Copyright © 2018 Zuri Wong. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {
    
    // Obtain the object reference to the App Delegate object
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet var oldPasswordTextField: UITextField!
    @IBOutlet var newPssswordTextField: UITextField!
    @IBOutlet var confirmNewPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        var noError = true
        
        if oldPasswordTextField.text == "" || newPssswordTextField.text == "" || confirmNewPasswordTextField.text == ""{
            showAlertMessage(messageHeader: "Missing Required Fields!", messageBody: "Please enter all required fields for this item")
            return false
        }
        appDelegate.login(email: appDelegate.currentUser.email, password: oldPasswordTextField.text!) { (success) in
            if !success {
                self.showAlertMessage(messageHeader: "Invalid Old Password", messageBody: "Please enter the correct old password!")
                noError = false
            }
        }
        
        if newPssswordTextField.text! != confirmNewPasswordTextField.text!{
            showAlertMessage(messageHeader: "Invalid New Password", messageBody: "New Password does not match!")
            return false
        }
        
        
        return noError
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
