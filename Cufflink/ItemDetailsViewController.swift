//
//  ItemDetailsViewController.swift
//  Cufflink
//
//  Created by Zuri Wong on 4/12/18.
//  Copyright © 2018 Zuri Wong. All rights reserved.
//

import UIKit
import CoreLocation
import MessageUI

class ItemDetailsViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var imagesPageControl: UIPageControl!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var ownerImageButton: UIButton?
    @IBOutlet var ownerNameLabel: UILabel?
    @IBOutlet var distanceLabel: UILabel?
    @IBOutlet var messageButton: UIButton!
    @IBOutlet var itemImageView: UIImageView!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var itemId: String!
    var item: ItemDetails!
    var timer: Timer!
    var updateCounter: Int!
    var userLocationPassed = CLLocation()
    var isUserItem = false
    var distanceToPass: String!
    var userName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.appDelegate.requestUrl("/items/\(itemId!)", nil) { (body, response) in
            self.item = ItemDetails(body as! NSDictionary)
            self.imagesPageControl.numberOfPages = self.item.pictures.count
            self.updateCounter = 0
            self.timer = Timer.scheduledTimer(
                timeInterval: 2.0,
                target: self,
                selector: #selector(ItemDetailsViewController.updateTimer),
                userInfo: nil,
                repeats: true
            )
            self.titleLabel.text! = self.item.title
            switch self.item.unitForPrice {
            case "perDay":
                self.priceLabel.text! = "$" + String(describing: self.item.price) + "/ Day"
                break
            case "perHour":
                self.priceLabel.text! = "$" + String(describing: self.item.price) + "/ Hour"
                break
            default:
                break
            }
            self.updateTimer()
            self.descriptionTextView.text! = self.item.details
            if self.ownerNameLabel != nil{
                 self.ownerNameLabel?.text = self.item.owner.name()
            }
           
            if self.item.owner.profile != ""{
                let profileStr = self.item.owner.profile
                let url = URL(string: profileStr)!
                let profileData = try? Data(contentsOf: url)
                if self.ownerImageButton != nil{
                    self.ownerImageButton?.setImage(UIImage(data: profileData!), for: .normal)
                    self.ownerImageButton?.imageView?.contentMode = UIViewContentMode.scaleAspectFill
                }
                
            }
            self.navigationItem.title = self.item.title
            let address = self.item.owner.location
            
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(address) { (placemarks, error) in
                guard
                    let placemarks = placemarks,
                    let ownerLocation = placemarks.first?.location
                    else {
                        // handle no location found
                        if self.distanceLabel != nil{
                            self.distanceLabel?.text = "unknown Miles away"
                        }
                        self.distanceToPass = "unknown Miles away"
                        return
                }
                
                // Calculate distance between user and owner in miles
                if self.distanceLabel != nil{
                    self.distanceLabel?.text = String(format: "%.1f", self.userLocationPassed.distance(from: ownerLocation) / 1609.34) + " Miles away"
                }
                
                self.distanceToPass = String(format: "%.1f", self.userLocationPassed.distance(from: ownerLocation) / 1609.34) + " Miles away"
                
                //if this item belongs to current user
                if self.item.owner.id == self.appDelegate.currentUser.id{
                    self.isUserItem = true
                    self.messageButton.removeFromSuperview()
                    self.distanceLabel?.text! = ""
                }
                
                
                
            }
          
        }
    }

    @objc internal func updateTimer(){
        if updateCounter < self.item.pictures.count {
            imagesPageControl.currentPage = updateCounter
            // Set Item Image
            itemImageView!.image = self.item.pictures[updateCounter]
            updateCounter = updateCounter + 1
        } else {
            updateCounter = 0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ownerImageButtonTapped(_ sender: UIButton) {
        //Check if owner is current user
        if item.owner.id == appDelegate.currentUser.id{
            performSegue(withIdentifier: "Show Personal Profile", sender: self)
            return
        }
        
        performSegue(withIdentifier: "Show Owner Profile", sender: self)
    }


    @IBAction func messageButtonTapped(_ sender: UIButton) {
        if !MFMessageComposeViewController.canSendText() {
            showAlertMessage(messageHeader: "Error", messageBody: "SMS services are not available!")
            return
        }
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.recipients = [self.item.owner.phone]
        composeVC.body = "Hello! My name is \(self.appDelegate.currentUser.name()). I am interested in  " + self.item.title +
            "on Cufflink. Can we talk?"
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)

    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult) {
        // Check the result or perform other tasks.
        
        // Dismiss the message compose view controller.
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    /*
     -------------------------
     MARK: - Prepare For Segue
     -------------------------
     */
    
    // This method is called by the system whenever you invoke the method performSegueWithIdentifier:sender:
    // You never call this method. It is invoked by the system.
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if segue.identifier == "Show Owner Profile" {
            
            // Obtain the object reference of the destination view controller
            let userProfileViewController: UserProfileViewController = segue.destination as! UserProfileViewController
            
            // Pass the data object to the downstream view controller object
            userProfileViewController.ownerPassed = item.owner
            userProfileViewController.navigationItem.title = item.owner.name()
            userProfileViewController.distancePassed = distanceToPass
            
        }else if segue.identifier == "Show Personal Profile"{
            // Obtain the object reference of the destination view controller
            let personalProfileViewController: PersonalProfileViewController = segue.destination as! PersonalProfileViewController
            
            // Pass the data object to the downstream view controller object
            personalProfileViewController.currentUserLocationPassed = userLocationPassed
            
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
