//
//  ItemDetailsViewController.swift
//  Cufflink
//
//  Created by Zuri Wong on 4/12/18.
//  Copyright © 2018 Zuri Wong. All rights reserved.
//

import UIKit

class ItemDetailsViewController: UIViewController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var imagesPageControl: UIPageControl!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var ownerImageButton: UIButton!
    @IBOutlet var ownerNameLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var messageButton: UIButton!
    @IBOutlet var itemImageView: UIImageView!

    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var itemId: String!
    var item: ItemDetails!
    var timer: Timer!
    var updateCounter: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //get current locaton --> distance
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
                self.priceLabel.text! = "$" + String(describing: self.item.price) + "/ Price"
                break
            default:
                break
            }
            self.updateTimer()
            self.descriptionTextView.text! = self.item.details
            self.ownerNameLabel.text = self.item.owner.name()

            self.navigationItem.title = self.item.title
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
        performSegue(withIdentifier: "Show Owner Profile", sender: self)
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
            
        }
    }
}
