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
    
    //---------- Create and Initialize the Array -----------------------
    var userEmails = [String]()
    
    @IBOutlet var emailTextField: UITextField!
    
    @IBOutlet var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userEmails = appDelegate.dict_UserEmail_UserData.allKeys as! [String]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func signInButtonTapped(_ sender: Any) {
        // Get the email entered by the user
        let emailObtained: String = emailTextField.text!

        // Get the password entered by the user
        let passwordObtained: String = passwordTextField.text!
//
//        /*********************
//         Input Data Validation
//         *********************/
//        if !isValidEmail(testStr: emailObtained){
//            showAlertMessage(messageHeader: "Invalid Email Entered!", messageBody: "Please enter a valid email")
//            return
//        }
//
//        if !userEmails.contains(emailObtained) {
//            showAlertMessage(messageHeader: "Invalid Email Entered!", messageBody: "Cannot find account")
//            return
//        }
//        // Obtain the list of data values of the given userEmail as AnyObject
//        let userDataObtained: AnyObject? = applicationDelegate.dict_UserEmail_UserData[emailObtained] as AnyObject
//
//        // Typecast the AnyObject to Swift array of String objects
//        var userData = userDataObtained! as! [String]
//
//        /*
//         userData[0] = User Name
//         userData[1] = User Password
//         */
//
//        let userPassword = userData[1] as String
//        if userPassword != passwordObtained{
//            showAlertMessage(messageHeader: "Invalid Password Entered!", messageBody: "Please enter a correct password")
//            return
//        }


        let url = URL(string: "https://cufflink-api-ksdqlxufqo.now.sh/login")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: [
                "email": emailObtained,
                "password": passwordObtained
            ], options: [])
            let task = appDelegate.session.dataTask(with: request) { (data, response, _) in
                let httpResponse = response! as! HTTPURLResponse
                do {
                    if (httpResponse.statusCode == 200) {
                        let values = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: String];
                        self.appDelegate.token = values["token"];
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "Show Home View", sender: self)
                        }
                    } else if httpResponse.statusCode == 400 {
                        DispatchQueue.main.async {
                            self.showAlertMessage(
                                messageHeader: "Invalid Login Credentials!",
                                messageBody: "Please enter a correct email and password"
                            )
                        }
                        print("fail")
                    } else {
                        print(httpResponse)
                        print(String(data: data!, encoding: .utf8)!)
                    }
                } catch {
                    print(error)
                }
            }
            task.resume()
        } catch {
            print(error)
        }
        
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
