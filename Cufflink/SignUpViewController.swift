//
//  SignUpViewController.swift
//  Cufflink
//
//  Created by Zuri Wong on 2/23/18.
//  Copyright © 2018 Zuri Wong. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
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
        let firstName = firstNameTextField.text!
        let lastName = lastNameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        //NEEDS TO BE TESTED, AND ADD MORE VALIDATION
        /*********************
         Input Data Validation
         *********************/
        if firstName.isEmpty{
            showAlertMessage(messageHeader: "No First Name Entered!", messageBody: "Please enter a First Name!")
            return
        }
        
        if lastName.isEmpty{
            showAlertMessage(messageHeader: "No Last Name Entered!", messageBody: "Please enter a Last Name!")
            return
        }
        
        if !isValidEmail(testStr: email){
            showAlertMessage(messageHeader: "Invalid Email Entered!", messageBody: "Please enter a valid email")
            return
        }
        
        if userEmails.contains(email) {
            showAlertMessage(messageHeader: "Account Found!", messageBody: "Cannot create multiple accounts using the same email")
            return
        }
        
        if password.isEmpty{
            showAlertMessage(messageHeader: "No Password Entered!", messageBody: "Please enter a Password!")
            return
        }
        
        if passwordTextField.text != confirmPasswordTextField.text{
            showAlertMessage(messageHeader: "Incorrect Password!", messageBody: "Please enter a valid password")
            return
        }
        
        let fullName = firstName + " " + lastName
        
        /*
         ------------------------------------------------------
         Create an array containing all of the user data.
         ------------------------------------------------------
         */
        let userData = [fullName, password, email]
        
        /*
         ---------------------------------------------------------------------
         Add the created array under the email key to the dictionary
         dict_UserEmail_UserData held by the app delegate object.
         ---------------------------------------------------------------------
         */
        //applicationDelegate.dict_UserEmail_UserData.setObject(userData, forKey: email as NSCopying)
        
        //userEmails = applicationDelegate.dict_UserEmail_UserData.allKeys as! [String]
        
        // Sort the userEmails within itself in alphabetical order
        userEmails.sort { $0 < $1 }
        
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
