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

    @IBOutlet var currentUserImageView: UIButton!
    @IBOutlet var currentUserNameLabel: UILabel!
    @IBOutlet var currentUserLocationLabel: UILabel!
    
    var currentUserLocationPassed = CLLocation()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let currentUser = appDelegate.currentUser
        currentUserNameLabel.text! = currentUser.name()
        
        //Making profile image view circular
        currentUserImageView.layer.borderWidth = 1
        currentUserImageView.layer.masksToBounds = false
        currentUserImageView.layer.borderColor = UIColor.white.cgColor
        currentUserImageView.layer.cornerRadius = currentUserImageView.frame.height/2
        currentUserImageView.clipsToBounds = true
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(currentUserLocationPassed, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            var location = ""
            
            // show location of the user
            let city = placeMark.addressDictionary!["City"] as! String
            let state = placeMark.addressDictionary!["State"] as! String
            location = city + ", " + state
            self.currentUserLocationLabel.text = location
            
            
        })
        
        if currentUser.profile != ""{
            currentUserImageView.setTitle("", for: .normal)
            let profileStr = currentUser.profile
            let url = URL(string: profileStr)!
            let profileData = try? Data(contentsOf: url)
            currentUserImageView.setImage(UIImage(data: profileData!)!, for: .normal)
            currentUserImageView.imageView?.contentMode = UIViewContentMode.scaleAspectFill
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    
    /*
     ---------------------------
     MARK: - Unwind Segue Method
     ---------------------------
     */
    @IBAction func unwindToPersonalProfileViewController(segue : UIStoryboardSegue) {
        if segue.identifier !=  "Settings-Done"  {
            return
        }
        
        // Obtain the object reference of the source view controller
        let settingsViewController: SettingsViewController = segue.source as! SettingsViewController
        var postString = [
            
        ]
        appDelegate.requestUrl("/me", <#T##body: Any?##Any?#>, completionHandler: <#T##(Any, HTTPURLResponse) -> Void#>)
     

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
    
}
