//
//  AddItemViewController.swift
//  Cufflink
//
//  Created by Zuri Wong on 4/18/18.
//  Copyright © 2018 Zuri Wong. All rights reserved.
//

import UIKit

class AddItemViewController: UIViewController {

    // Obtain the object reference to the App Delegate object
    var appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet var itemTitleTextField: UITextField!
    @IBOutlet var itemPriceTextField: UITextField!
    @IBOutlet var addImageOneButton: UIButton!
    @IBOutlet var addImageTwoButton: UIButton!
    @IBOutlet var addImageThreeButton: UIButton!
    @IBOutlet var doneEditingButton: UIButton!
    @IBOutlet var itemDescriptionTextView: UITextView!
    @IBOutlet var priceUnitSegmentControl: UISegmentedControl!
    
    var imageButtonTagToPass = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addImageOneButton.layer.borderWidth = 1
        addImageTwoButton.layer.borderWidth = 1
        addImageThreeButton.layer.borderWidth = 1
        doneEditingButton.layer.cornerRadius = 20
        doneEditingButton.clipsToBounds = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func imageButtonTapped(_ sender: UIButton) {
        imageButtonTagToPass = sender.tag
        performSegue(withIdentifier: "Choose Image", sender: self)
    }
    
    /*
     ---------------------------
     MARK: - Unwind Segue Method
     ---------------------------
     */
    @IBAction func unwindToAddItemViewController(segue : UIStoryboardSegue) {
        if segue.identifier !=  "ChooseImage-Done"  {
            return
        }
        // Obtain the object reference of the source view controller
        let chooseImageViewController: ChooseImageViewController = segue.source as! ChooseImageViewController
        
        switch imageButtonTagToPass {
        case 1:
            addImageOneButton.setBackgroundImage(chooseImageViewController.chosenImage1, for: .normal)
        case 2:
            addImageTwoButton.setBackgroundImage(chooseImageViewController.chosenImage2, for: .normal)
        case 3:
            addImageThreeButton.setBackgroundImage(chooseImageViewController.chosenImage3, for: .normal)
        default:
            return
        }
        
        
        
    }
    /*
     -------------------------
     MARK: - Prepare For Segue
     -------------------------
     */
    
    // This method is called by the system whenever you invoke the method performSegueWithIdentifier:sender:
    // You never call this method. It is invoked by the system.
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if segue.identifier == "Choose Image" {
            
            // Obtain the object reference of the source view controller
            let chooseImageViewController: ChooseImageViewController = segue.source as! ChooseImageViewController
            
            // Pass the data object to the downstream view controller object
            chooseImageViewController.imageButtonTagPassed = imageButtonTagToPass
            
        }
    }
    
    @IBAction func doneAddingButtonTapped(_ sender: UIButton) {
        //Add verification to this...
        
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
