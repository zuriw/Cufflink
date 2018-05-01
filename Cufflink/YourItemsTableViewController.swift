//
//  YourItemsTableViewController.swift
//  Cufflink
//
//  Created by Christian Howe on 4/18/18.
//  Copyright © 2018 Zuri Wong. All rights reserved.
//

import UIKit
import CoreLocation

class YourItemsTableViewController: UITableViewController, CLLocationManagerDelegate{

    // Obtain the object reference to the App Delegate object
    var appDelegate = UIApplication.shared.delegate as! AppDelegate

    var items: [Item] = []
    var itemToEdit: ItemDetails!

    let tableViewRowHeight: CGFloat = 70.0

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        items.removeAll()
        self.appDelegate.requestUrl("/me/items", nil) { (body, response) in
            let array = body as! [NSDictionary]
            self.items = array.map { Item($0) }
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    let green = UIColor(red: 86.0/255.0, green: 136.0/255.0, blue: 102.0/255.0, alpha: 0.5)
    let red = UIColor(red: 148.0/255.0, green: 23.0/255.0, blue: 81.0/255.0, alpha: 1.0)

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Your Item Cell", for: indexPath) as! YourItemTableViewCell

        // get the item for the current indexPath
        let item = items[indexPath.row]

        // set the item's thumbnail, title, and price
        cell.itemImageView!.image = item.thumbnail
        cell.itemTitleLabel!.text = item.title
        cell.itemPriceLabel!.text = item.price
        cell.itemPriceUnitLabel!.text = item.unitForPrice == "perDay" ? "/Day" : "/Hour"
        cell.availableLabel!.text = item.available ? "Available" : "Unavailable"
        cell.availableLabel!.backgroundColor = item.available ? green : red
        cell.availableLabel!.textColor = item.available ? UIColor.black : UIColor.white

        return cell
    }


    /*
     -----------------------------------
     MARK: - Table View Delegate Methods
     -----------------------------------
     */

    // Asks the table view delegate to return the height of a given row.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewRowHeight
    }


    //---------------------------
    // Item (Row) Selected
    //---------------------------

    // Tapping a row (Item) displays Item Details
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // get the item to edit
        self.appDelegate.requestUrl("/items/\(items[indexPath.row].id)", nil) { (body, response) in
            self.itemToEdit = ItemDetails(body as! NSDictionary)
            self.performSegue(withIdentifier: "Edit Item Details", sender: self)
        }
    }

    /*
     ---------------------------
     MARK: - Unwind Segue Method
     ---------------------------
     */
    @IBAction func unwindToYourItemsTableViewController(segue : UIStoryboardSegue) {
        if segue.identifier != "Edit Item"  {
            return
        }

        // Obtain the object reference of the source view controller
        let editItemViewController: EditItemViewController = segue.source as! EditItemViewController
        var images = [UIImage]()

        if editItemViewController.chosenImageOnePassed != nil {
            images.append(editItemViewController.chosenImageOnePassed!)
        }

        if editItemViewController.chosenImageTwoPassed != nil {
            images.append(editItemViewController.chosenImageTwoPassed!)
        }

        if editItemViewController.chosenImageThreePassed != nil {
            images.append(editItemViewController.chosenImageThreePassed!)
        }

        appDelegate.upload(images: images) { (urls) in
            let postString = [
                "title": editItemViewController.itemTitleTextField.text!,
                "price": editItemViewController.itemPriceTextField.text!,
                "unitForPrice": editItemViewController.priceUnitSegmentControl.selectedSegmentIndex == 0 ? "perHour" : "perDay",
                "pictures": urls,
                "details": editItemViewController.itemDescriptionTextView.text!,
                "available": editItemViewController.availableSegmentedControl.selectedSegmentIndex == 0
            ] as [String : Any]

            self.appDelegate.requestUrl("/items/\(editItemViewController.itemToEdit.id)", postString){ (body, response) in
                self.viewWillAppear(true)
            }

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
        if segue.identifier == "Edit Item Details" {
            // Obtain the object reference of the destination view controller
            let editItemViewController: EditItemViewController = segue.destination as! EditItemViewController

            // pass the the item to edit to the downstream view controller object
            editItemViewController.itemToEdit = itemToEdit
            editItemViewController.justSegued = true
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
