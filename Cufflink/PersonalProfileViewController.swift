//
//  PersonalProfileViewController.swift
//  Cufflink
//
//  Created by Zuri Wong on 4/29/18.
//  Copyright © 2018 Zuri Wong. All rights reserved.
//

import UIKit
import CoreLocation

class PersonalProfileViewController: UIViewController {
    
    // Obtain the object reference to the App Delegate object
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    @IBOutlet var currentUserImageView: UIImageView!
    @IBOutlet var currentUserNameLabel: UILabel!
    @IBOutlet var currentUserLocationLabel: UILabel!
    
    var currentUserLocationPassed = CLLocation()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.requestUrl("/me", nil){ (body, response) in
            var currentUser = User(body as! NSDictionary)
            self.currentUserNameLabel.text! = currentUser.name()
            
            //Making profile image view circular
            self.currentUserImageView.layer.borderWidth = 1
            self.currentUserImageView.layer.masksToBounds = false
            self.currentUserImageView.layer.borderColor = UIColor.white.cgColor
            self.currentUserImageView.layer.cornerRadius = self.currentUserImageView.frame.height/2
            self.currentUserImageView.clipsToBounds = true
            
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(self.currentUserLocationPassed, completionHandler: { (placemarks, error) -> Void in
                
                // Place details
                var placeMark: CLPlacemark!
                placeMark = placemarks?[0]
                var location = ""
                
                // show location of the user
                let city = placeMark.addressDictionary!["City"] as! String
                let state = placeMark.addressDictionary!["State"] as! String
                location = city + ", " + state
                self.currentUserLocationLabel.text = location
                
                
                
                
                if currentUser.profile != ""{
                    let profileStr = currentUser.profile
                    let url = URL(string: profileStr)!
                    let profileData = try? Data(contentsOf: url)
                    self.currentUserImageView.image = UIImage(data: profileData!)
                }
                
                
            })
        }
        
        
        //let currentUser = appDelegate.currentUser
        
    }
    
    
    /*
     ---------------------------
     MARK: - Unwind Segue Method
     ---------------------------
     */
    @IBAction func unwindToPersonalProfileViewController(segue : UIStoryboardSegue) {
        if segue.identifier ==  "Settings-Done" {
            // Obtain the object reference of the source view controller
            let settingsViewController: SettingsViewController = segue.source as! SettingsViewController
            if settingsViewController.profilePicture != nil{
                var images = [UIImage]()
                images.append(settingsViewController.profilePicture!)
                appDelegate.upload(images: images){(urls) in
                    let postString = [
                        "location": "\(settingsViewController.addressTextField.text!), \(settingsViewController.cityTextField.text!), \(settingsViewController.stateTextField.text!)",
                        "firstName": settingsViewController.firstNameTextField.text!,
                        "lastName": settingsViewController.lastNameTextField.text!,
                        "profile": urls[0],
                        "phone": settingsViewController.phoneTextField.text!
                        ] as [String : Any]
                    
                    
                    self.appDelegate.requestUrl("/me", postString){(body, response) in
                        self.viewDidLoad()
                    }
                }
            }else{
                let postString = [
                    "location": "\(settingsViewController.addressTextField.text!), \(settingsViewController.cityTextField.text!), \(settingsViewController.stateTextField.text!)",
                    "firstName": settingsViewController.firstNameTextField.text!,
                    "lastName": settingsViewController.lastNameTextField.text!,
                    "phone": settingsViewController.phoneTextField.text!
                    ] as [String : Any]
                
                
                self.appDelegate.requestUrl("/me", postString){(body, response) in
                    
                }
            }
            
            
        }
        
        return
    }
    
    
    @IBAction func settingButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "Show Settings", sender: self)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logOutButtonTapped(_ sender: UIButton) {
        
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LogInViewController") as! LogInViewController
        
        let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDel.window?.rootViewController = loginVC
        
        
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
