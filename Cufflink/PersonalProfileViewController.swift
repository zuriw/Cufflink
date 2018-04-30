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
            
            // Address dictionary
            print(placeMark.addressDictionary as Any)
            
            // Location name
            if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
                print(locationName)
            }
            // Street address
            if let street = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
                print(street)
            }
            // City
            if let city = placeMark.addressDictionary!["City"] as? NSString {
                print(city)
            }
            // Zip code
            if let zip = placeMark.addressDictionary!["ZIP"] as? NSString {
                print(zip)
            }
            // Country
            if let country = placeMark.addressDictionary!["Country"] as? NSString {
                print(country)
            }
        })
        
        
        // Do any additional setup after loading the view.
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

}
