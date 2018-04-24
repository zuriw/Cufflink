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
    
    func requestUrl(_ string: String, _ body: Any?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let url = URL(string: string)
        var request = URLRequest(url: url!)
        request.httpMethod = body == nil ? "GET" : "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if appDelegate.token != nil {
            request.addValue(appDelegate.token, forHTTPHeaderField: "token")
        }
        do {
            if body != nil {
                request.httpBody = try JSONSerialization.data(withJSONObject: body!, options: [])
            }
            let task = self.appDelegate.session.dataTask(with: request)
            task.resume()
        } catch {
            print(error)
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        /*********************
         Input Data Validation
         *********************/
        
        if emailObtained.isEmpty || passwordObtained.isEmpty{
            showAlertMessage(messageHeader: "Missing Information", messageBody: "One of the required fields is missing")
            return
        }
        
        if !isValidEmail(testStr: emailObtained){
            showAlertMessage(messageHeader: "Invalid Email Entered!", messageBody: "Please enter a valid email")
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
        let url = URL(string: "https://cufflink-api-ksdqlxufqo.now.sh/login")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // Setting the content-type as JSON
        request.addValue("application/json", forHTTPHeaderField: "Accept") //Setting the result content-type as JSON
        let postString = [
            "email": emailObtained,
            "password": passwordObtained
            ] as [String: String]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postString, options: .prettyPrinted)
            
        } catch let error{
            print(error.localizedDescription)
            showAlertMessage(messageHeader: "Error occurred while retriving data", messageBody: "Please make sure all required fields are entered!")
            return
        }
        
        let task = appDelegate.session.dataTask(with: request) { (data, response: URLResponse?, error: Error?) in
            self.removeActivityIndicator(activityIndicator: myActivityIndicator)
            if error != nil {
                self.showAlertMessage(messageHeader: "Error occured while HTTP requesting", messageBody: "Please try again later!")
                return
            }
            
            //Convert response sent from a server side code to a NSDictionary object
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: String]
                if let parseJSON = json{
                    let accessToken = parseJSON["token"]
                    
                    if accessToken == nil{
                        self.removeActivityIndicator(activityIndicator: myActivityIndicator)
                        self.showAlertMessage(messageHeader: "Error occured while getting request response", messageBody: "Please try again later!") //CRASH
                        return
                    }
                    self.appDelegate.token = accessToken
                    print("Access token: \(String(accessToken!))")
                    
                    let url = URL(string: "http://cufflink-api.now.sh/items")
                    let task = self.appDelegate.session.dataTask(with: url!) { (data,_,_) in
                        guard let data = data else {return}
                        do{
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            //print(json)
                            if let array = json as? NSArray{
                                //print(array)
                                
                                let dict = array[0] as! NSDictionary
                                let id = dict["_id"] as! String
                                
                                //Get Item Details from id
                                self.requestUrl("http://cufflink-api.now.sh/items/\(String(id))", nil) { (data,_,_) in
                                    guard let data = data else {return}
                                    do{
                                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                                        if let myItem = json as? NSDictionary{
                                            let title = myItem["title"] as! String
                                            let imageUrls = myItem["pictures"] as! NSArray
                                            let price = myItem["price"] as! NSNumber
                                            let id = myItem["_id"] as! String
                                            let priceUnit = myItem["unitForPrice"] as! String
                                            let description = myItem["description"] as! String
                                            var myOwner = NSDictionary()
                                            myOwner = myItem["owner"] as! NSDictionary
                                            let user = User(name: myOwner["name"] as! String, email: myOwner["email"] as! String, image: "", phone: "", location: myOwner["zipcode"] as! NSNumber)
                                            
                                            let item = Item(title: title, images: imageUrls as! [String], id: id, available: false, price: price, priceUnit: priceUnit, details: description, Owner: user)
                                            self.appDelegate.items[id] = item
                                            
                                            DispatchQueue.main.async{
                                                let homePage = self.storyboard?.instantiateViewController(withIdentifier: "HomeTableViewController") as! HomeTableViewController
                                                self.appDelegate.window?.rootViewController = homePage
                                            }
                                            
                                        }
                                    } catch {}
                                    
                                }
                            }
                            
                        } catch {}
                        
                    }
                    task.resume()
                    
                   
   
                }else{
                    //self.removeActivityIndicator(activityIndicator: myActivityIndicator)
                    self.showAlertMessage(messageHeader: "Error occured while getting request response", messageBody: "Please try again later!")
                    return
                }
            }catch {
                self.removeActivityIndicator(activityIndicator: myActivityIndicator)
                self.showAlertMessage(messageHeader: "Error occured while getting request response", messageBody: "Please try again later!")
                return
            }
            
        }
        
        task.resume()
        
    }
    
    
    
    
    
    //        let url = URL(string: "https://cufflink-api-ksdqlxufqo.now.sh/login")
    //        var request = URLRequest(url: url!)
    //        request.httpMethod = "POST"
    //        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    //        do {
    //            request.httpBody = try JSONSerialization.data(withJSONObject: [
    //                "email": emailObtained,
    //                "password": passwordObtained
    //            ], options: [])
    //            let task = appDelegate.session.dataTask(with: request) { (data, response, _) in
    //                let httpResponse = response! as! HTTPURLResponse
    //                do {
    //                    if (httpResponse.statusCode == 200) {
    //                        let values = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: String];
    //                        print(values["token"] as String!)
    //                        self.token = values["token"] as String!
    //
    //
    //                        let url = URL(string: "http://cufflink-api.now.sh/items")
    //                        let task = self.appDelegate.session.dataTask(with: url!) { (data,_,_) in
    //                            guard let data = data else {return}
    //                            do{
    //                                let json = try JSONSerialization.jsonObject(with: data, options: [])
    //                                //print(json)
    //                                if let array = json as? NSArray{
    //                                    //print(array)
    //
    //                                    let dict = array[0] as! NSDictionary
    //                                    let id = dict["_id"] as! String
    //
    //                                    //Get Item Details from id
    //                                    self.requestUrl("http://cufflink-api.now.sh/items/\(String(id))", nil) { (data,_,_) in
    //                                        guard let data = data else {return}
    //                                        do{
    //                                            let json = try JSONSerialization.jsonObject(with: data, options: [])
    //                                            if let myItem = json as? NSDictionary{
    //                                                let title = myItem["title"] as! String
    //                                                let imageUrls = myItem["pictures"] as! NSArray
    //                                                let price = myItem["price"] as! NSNumber
    //                                                let id = myItem["_id"] as! String
    //                                                let priceUnit = myItem["unitForPrice"] as! String
    //                                                let description = myItem["description"] as! String
    //                                                var myOwner = NSDictionary()
    //                                                myOwner = myItem["owner"] as! NSDictionary
    //                                                let user = User(name: myOwner["name"] as! String, email: myOwner["email"] as! String, image: "", phone: "", location: myOwner["zipcode"] as! NSNumber)
    //
    //                                                let item = Item(title: title, images: imageUrls as! [String], id: id, available: false, price: price, priceUnit: priceUnit, details: description, Owner: user)
    //                                                self.items[id] = item
    //                                                self.appDelegate.items = self.items
    //                                                DispatchQueue.main.async {
    //                                                    self.performSegue(withIdentifier: "Show Home View", sender: self)
    //                                                }
    //
    //                                            }
    //                                        } catch {}
    //
    //                                    }
    //                                }
    //
    //                            } catch {}
    //
    //                        }
    //                        task.resume()
    //
    //                    } else if httpResponse.statusCode == 400 {
    //                        DispatchQueue.main.async {
    //                            self.showAlertMessage(
    //                                messageHeader: "Invalid Login Credentials!",
    //                                messageBody: "Please enter a correct email and password"
    //                            )
    //                        }
    //                        print("fail")
    //                    } else {
    //                        print(httpResponse)
    //                        print(String(data: data!, encoding: .utf8)!)
    //                    }
    //                } catch {
    //                    print(error)
    //                }
    //            }
    //            task.resume()
    //        } catch {
    //            print(error)
    //        }
    
    //}
    
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
    
    /*
     -----------------------------
     MARK: - Display Alert Message
     -----------------------------
     */
    func removeActivityIndicator(activityIndicator: UIActivityIndicatorView){
        DispatchQueue.main.async{
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
    
    
}


