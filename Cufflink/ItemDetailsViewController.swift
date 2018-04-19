//
//  ItemDetailsViewController.swift
//  Cufflink
//
//  Created by Zuri Wong on 4/12/18.
//  Copyright © 2018 Zuri Wong. All rights reserved.
//

import UIKit

class ItemDetailsViewController: UIViewController {

    var itemPassed = Item(title: "", images: [], id: "", price: 0, priceUnit: "", details: "", Owner: User(name: "", email: "", image: "", phone: "", location: 0))
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var imagesPageControl: UIPageControl!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var ownerImageButton: UIButton!
    @IBOutlet var ownerNameLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var messageButton: UIButton!
    @IBOutlet var itemImageView: UIImageView!
    var timer: Timer!
    var updateCounter: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagesPageControl.numberOfPages = itemPassed.images.count
        updateCounter = 0
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(ItemDetailsViewController.updateTimer), userInfo: nil, repeats: true)
        titleLabel.text! = itemPassed.title
        switch itemPassed.priceUnit{
        case "perDay":
            priceLabel.text! = "$" + String(describing: itemPassed.price) + "/ Day"
            break
        case "perHour":
            priceLabel.text! = "$" + String(describing: itemPassed.price) + "/ Price"
            break
        default:
            break
        }
        
        descriptionTextView.text! = itemPassed.details
        ownerNameLabel.text = itemPassed.Owner.name
        //get current locaton --> distance
        
        
        
    }
    
    @objc internal func updateTimer(){
        if updateCounter < itemPassed.images.count{
            imagesPageControl.currentPage = updateCounter
            // Set Item Image
            if itemPassed.images[updateCounter] == ""{
                print("no thumbnail")
            }else{
                let url = URL(string: itemPassed.images[updateCounter])
                let itemImageData = try? Data(contentsOf: url!)
                if let imageData = itemImageData {
                    itemImageView!.image = UIImage(data: imageData)
                } else {
                    print("no thumbnail")
                }
            }
            updateCounter = updateCounter + 1
        }else{
            updateCounter = 0
        }
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
