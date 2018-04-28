//
//  LogInViewController.swift
//  Cufflink
//
//  Created by Zuri Wong on 2/23/18.
//  Copyright © 2018 Zuri Wong. All rights reserved.
//

import UIKit



class LogInViewController: UIViewController {
    
    // Obtain the object reference to the App Delegate object
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        // Get the email entered by the user
        let emailObtained: String = emailTextField.text!
        
        // Get the password entered by the user
        let passwordObtained: String = passwordTextField.text!
        
        /*********************
         Input Data Validation
         *********************/
        
        if emailObtained.isEmpty || passwordObtained.isEmpty{
            self.showAlertMessage(messageHeader: "Missing Information", messageBody: "One of the required fields is missing")
            return
        }
        
        if !self.isValidEmail(testStr: emailObtained){
            self.showAlertMessage(messageHeader: "Invalid Email Entered!", messageBody: "Please enter a valid email")
            return
        }
        
        /***************************
         Indicate Activity is loading
         ****************************/
        
        //Create Activity Indicator
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        
        //Position Activity Indicator in the center of the main view
        myActivityIndicator.center = view.center
        
        myActivityIndicator.hidesWhenStopped = false
        
        //Start Activity Indicator
        myActivityIndicator.startAnimating()
        
        view.addSubview(myActivityIndicator)
        
        //send HTTP request to perform Log in
        self.appDelegate.login(email: emailObtained, password: passwordObtained) { (success) in
            myActivityIndicator.stopAnimating()
            myActivityIndicator.removeFromSuperview()
            if success == false {
                // show user alert when login credentials are incorrect
                self.showAlertMessage(
                    messageHeader: "Invalid Login!",
                    messageBody: "Username or password incorrect"
                )
                return
            } else {
                self.performSegue(withIdentifier: "Show Home View", sender: self)
            }
        }
    }
}


