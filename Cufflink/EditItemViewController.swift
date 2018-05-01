//
//  EditItemViewController.swift
//  Cufflink
//
//  Created by Christian Howe on 4/18/18.
//  Copyright © 2018 Zuri Wong. All rights reserved.
//

import UIKit

class EditItemViewController: UIViewController {

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
    @IBOutlet var availableSegmentedControl: UISegmentedControl!
    
    var chosenImageOnePassed: UIImage?
    var chosenImageTwoPassed: UIImage?
    var chosenImageThreePassed: UIImage?

    var imageButtonTagToPass: Int!
    var itemToEdit: ItemDetails!

    var justSegued = false

    override func viewDidLoad() {
        super.viewDidLoad()
        addImageOneButton.layer.borderWidth = 1
        addImageTwoButton.layer.borderWidth = 1
        addImageThreeButton.layer.borderWidth = 1
        doneEditingButton.layer.cornerRadius = 20
        doneEditingButton.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        if justSegued {
            itemTitleTextField.text = itemToEdit.title
            itemPriceTextField.text = itemToEdit.price
            itemDescriptionTextView.text = itemToEdit.details
            priceUnitSegmentControl.selectedSegmentIndex = itemToEdit.unitForPrice == "perHour" ? 0 : 1
            availableSegmentedControl.selectedSegmentIndex = itemToEdit.available ? 0 : 1

            addImageOneButton.setTitle("", for: .normal)
            addImageOneButton.setBackgroundImage(itemToEdit.pictures[0], for: .normal)
            chosenImageOnePassed = itemToEdit.pictures[0]

            if itemToEdit.pictures.count > 1 {
                addImageTwoButton.setTitle("", for: .normal)
                addImageTwoButton.setBackgroundImage(itemToEdit.pictures[1], for: .normal)
                chosenImageTwoPassed = itemToEdit.pictures[1]
            }

            if itemToEdit.pictures.count > 2 {
                addImageThreeButton.setTitle("", for: .normal)
                addImageThreeButton.setBackgroundImage(itemToEdit.pictures[2], for: .normal)
                chosenImageThreePassed = itemToEdit.pictures[2]
            }

            justSegued = false
        }
    }

    @IBAction func imageButtonTapped(_ sender: UIButton) {
        imageButtonTagToPass = sender.tag
        performSegue(withIdentifier: "Edit Image", sender: self)
    }

    /*
     ---------------------------
     MARK: - Unwind Segue Method
     ---------------------------
     */
    @IBAction func unwindToEditItemViewController(segue : UIStoryboardSegue) {
        if segue.identifier !=  "Edited Image"  {
            return
        }

        // Obtain the object reference of the source view controller
        let chooseImageViewController: ChooseImageViewController = segue.source as! ChooseImageViewController
        switch chooseImageViewController.imageButtonTagPassed {
        case 1:
            addImageOneButton.setTitle("", for: .normal)
            addImageOneButton.setBackgroundImage(chooseImageViewController.chosenImage1, for: .normal)
            chosenImageOnePassed = chooseImageViewController.chosenImage1
        case 2:
            addImageTwoButton.setTitle("", for: .normal)
            addImageTwoButton.setBackgroundImage(chooseImageViewController.chosenImage2, for: .normal)
            chosenImageTwoPassed = chooseImageViewController.chosenImage2
        case 3:
            addImageThreeButton.setTitle("", for: .normal)
            addImageThreeButton.setBackgroundImage(chooseImageViewController.chosenImage3, for: .normal)
            chosenImageThreePassed = chooseImageViewController.chosenImage3
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
        if segue.identifier == "Edit Image" {
            // Obtain the object reference of the source view controller
            let chooseImageViewController: ChooseImageViewController = segue.destination as! ChooseImageViewController

            // Pass the data object to the downstream view controller object
            chooseImageViewController.imageButtonTagPassed = imageButtonTagToPass
            chooseImageViewController.chosenImage = UIImage()
            chooseImageViewController.chosenImage1 = UIImage()
            chooseImageViewController.chosenImage2 = UIImage()
            chooseImageViewController.chosenImage3 = UIImage()
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //Add verification to this...
        if itemTitleTextField.text == "" || itemPriceTextField.text == "" || itemDescriptionTextView.text == ""{
            showAlertMessage(messageHeader: "Missing Required Fields!", messageBody: "Please enter all required fields for this item")
            return false
        }

        if addImageOneButton.backgroundImage(for: .normal) == nil && addImageTwoButton.backgroundImage(for: .normal) == nil && addImageThreeButton.backgroundImage(for: .normal) == nil{
            showAlertMessage(messageHeader: "Missing Images!", messageBody: "Please add at least one image to your item")
            return false
        }


        return true
    }

    /*
     ------------------------
     MARK: - IBAction Methods
     ------------------------
     */
    @IBAction func keyboardDone(_ sender: UITextField) {

        // When the Text Field resigns as first responder, the keyboard is automatically removed.
        sender.resignFirstResponder()
    }

    @IBAction func backgroundTouch(_ sender: UIControl) {
        /*
         "This method looks at the current view and its subview hierarchy for the text field that is
         currently the first responder. If it finds one, it asks that text field to resign as first responder.
         If the force parameter is set to true, the text field is never even asked; it is forced to resign." [Apple]

         When the Text Field resigns as first responder, the keyboard is automatically removed.
         */
        view.endEditing(true)
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
