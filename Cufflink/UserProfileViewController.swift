//
//  UserProfileViewController.swift
//  Cufflink
//
//  Created by Zuri Wong on 4/19/18.
//  Copyright © 2018 Zuri Wong. All rights reserved.
//

import UIKit
import CoreLocation
import MessageUI

class UserProfileViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
    // Obtain the object reference to the App Delegate object
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userGeneralLocationLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    
    var ownerPassed: User!
    var distancePassed: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameLabel.text! = ownerPassed.name()
        
        //Making profile picture image view circular
        userImageView.layer.borderWidth = 1
        userImageView.layer.masksToBounds = false
        userImageView.layer.borderColor = UIColor.white.cgColor
        userImageView.layer.cornerRadius = userImageView.frame.height/2
        userImageView.clipsToBounds = true
        
        if ownerPassed.profile != ""{
            let profileStr = ownerPassed.profile
            let url = URL(string: profileStr)!
            let profileData = try? Data(contentsOf: url)
            self.userImageView.image = UIImage(data: profileData!)
        }
        
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(ownerPassed.location) { (placemarks, error) in
                
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            var location = ""
            
            // show location of the user
            let city = placeMark.addressDictionary!["City"] as! String
            let state = placeMark.addressDictionary!["State"] as! String
            location = city + ", " + state
            self.userGeneralLocationLabel.text = location

        }
            
            distanceLabel.text! = distancePassed
            // Do any additional setup after loading the view.
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
    @IBAction func messageButtonTapped(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let currentUser = appDelegate.currentUser
        
        if !MFMessageComposeViewController.canSendText() {
            showAlertMessage(messageHeader: "Error", messageBody: "SMS services are not available!")
            return
        }
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.recipients = [ownerPassed.phone]
        composeVC.body = "Hello! My name is \(currentUser.name()).Can we talk?"
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult) {
        // Check the result or perform other tasks.
        
        // Dismiss the message compose view controller.
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func userItemsButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "Show Owner Items", sender: self)
    }
    
    /*
     -------------------------
     MARK: - Prepare For Segue
     -------------------------
     */
    
    // This method is called by the system whenever you invoke the method performSegueWithIdentifier:sender:
    // You never call this method. It is invoked by the system.
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if segue.identifier == "Show Owner Items" {
            
            // Obtain the object reference of the destination view controller
            let userItemsTableViewController: UserItemsTableViewController = segue.destination as! UserItemsTableViewController
            
            // Pass the data object to the downstream view controller object
            userItemsTableViewController.idPassed = ownerPassed.id
            userItemsTableViewController.navigationItem.title = "\(ownerPassed.name())'s Items"
            
            
        }
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
