//
//  SignUpViewController.swift
//  Cufflink
//
//  Created by Zuri Wong on 2/23/18.
//  Copyright © 2018 Zuri Wong. All rights reserved.
//

import UIKit
import CoreLocation

class SignUpViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var phoneNumberTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var cityTextField: UITextField!
    @IBOutlet var stateTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmPasswordTextField: UITextField!
    
    // Obtain the object reference to the App Delegate object
    let applicationDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //---------- Create and Initialize the Array -----------------------
    var userEmails = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //userEmails = applicationDelegate.dict_UserEmail_UserData.allKeys as! [String]
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        let firstNameObtained = firstNameTextField.text!
        let lastNameObtained = lastNameTextField.text!
        let phoneObtained = phoneNumberTextField.text!
        let addressObtained = addressTextField.text!
        let cityObtained = cityTextField.text!
        let stateObtained = stateTextField.text!
        let emailObtained = emailTextField.text!
        let passwordObtained = passwordTextField.text!
        
        
        let location = addressObtained + ", " + cityObtained + ", " + stateObtained

        /*********************
         Input Data Validation
         *********************/
        
        
        //validate email
        if !isValidEmail(testStr: emailObtained){
            showAlertMessage(messageHeader: "Invalid Email Entered!", messageBody: "Please enter a valid email")
            return
        }
        
        //validate password
        if passwordTextField.text != confirmPasswordTextField.text{
            showAlertMessage(messageHeader: "Incorrect Password!", messageBody: "Please enter a valid password")
            return
        }
        
        
       //validate phone
        if phoneObtained.count < 10{
            self.showAlertMessage(messageHeader: "Invalid Phone Number!", messageBody: "Please enter a phone number with 10 digits")
            return
        }
        
        //validate location
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(location) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let ownerLocation = placemarks.first?.location
                else {
                    // handle no location found
                    self.showAlertMessage(messageHeader: "Invalid Address!", messageBody: "Please enter a valid address")
                    return
            }
            /***************************
             Indicate Activity is loading
             ****************************/
            
            //Create Activity Indicator
            let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
            
            //Position Activity Indicator in the center of the main view
            myActivityIndicator.center = self.view.center
            
            myActivityIndicator.hidesWhenStopped = false
            
            //Start Activity Indicator
            myActivityIndicator.startAnimating()
            
            self.view.addSubview(myActivityIndicator)
            
            //send HTTP request to perform Log in
            self.applicationDelegate.signUp(firstName: firstNameObtained, lastName: lastNameObtained, phone: phoneObtained, email: emailObtained, location: location, password: passwordObtained) { (success) in
                myActivityIndicator.stopAnimating()
                myActivityIndicator.removeFromSuperview()
                if success == false {
                    // show user alert when login credentials are incorrect
                    self.showAlertMessage(
                        messageHeader: "Invalid SignUp!",
                        messageBody: "Required fields not completed or account already exist"
                    )
                    return
                } else {
                    //Log in to get a token
                    //send HTTP request to perform Log in
                    self.applicationDelegate.login(email: emailObtained, password: passwordObtained) { (success) in
                        myActivityIndicator.stopAnimating()
                        myActivityIndicator.removeFromSuperview()
                        if success == false {
                            // show user alert when login credentials are incorrect
                            self.showAlertMessage(
                                messageHeader: "Error",
                                messageBody: "Something is wrong..."
                            )
                            return
                        } else {
                            
                            self.performSegue(withIdentifier: "Show Congrats", sender: self)
                        }
                    }
                    
                }
            }
        }
        
       
       
    }
    
    /*
     ------------------------------------
     MARK: - UITextField Delegate Methods
     ------------------------------------
     */
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //anything that has delegate but phoneNumber
        if textField.tag == 0 || textField.tag == 2{
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame = CGRect(x:self.view.frame.origin.x, y:self.view.frame.origin.y - 200, width:self.view.frame.size.width, height:self.view.frame.size.height);
                
            })
        }
      
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //anything that has delegate but phoneNumber
        if textField.tag == 0 || textField.tag == 2{
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame = CGRect(x:self.view.frame.origin.x, y:self.view.frame.origin.y + 200, width:self.view.frame.size.width, height:self.view.frame.size.height);
                
            })
        }
        
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //Only Phone Number Tag is 1, and State Tag is 2, rest is 0
        if textField.tag == 1{ //Phone Number
            guard let text = textField.text else { return true }
            let newLength = text.characters.count + string.characters.count - range.length
            return newLength <= 10 // Bool
        }else if textField.tag == 2{ //State
            guard let text = textField.text else { return true }
            let newLength = text.characters.count + string.characters.count - range.length
            return newLength <= 2 // Bool
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
     MARK: - Validate email address
     -----------------------------
     */
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
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
