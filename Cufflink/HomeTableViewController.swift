//
//  HomeTableViewController.swift
//  Cufflink
//
//  Created by Zuri Wong on 4/9/18.
//  Copyright © 2018 Zuri Wong. All rights reserved.
//

import UIKit
import CoreLocation

struct Item {
    let title: String
    var images: [String]
    let id: String
    var available: Bool
    let price: NSNumber
    let priceUnit: String
    var details: String
    var Owner: User
    
}

struct User{
    let name: String
    let email: String
    let image: String
    let phone: String
    let location: NSNumber
}


class HomeTableViewController: UITableViewController, CLLocationManagerDelegate{

    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var itemIDs = [String]()
    var dict_id_item = [String: Item]()
    var session = URLSession.shared
    var itemToPass = Item(title: "", images: [], id: "", available: false, price: 0, priceUnit: "", details: "", Owner: User(name: "", email: "", image: "", phone: "", location: 0))
    let tableViewRowHeight: CGFloat = 70.0
    
    // Instantiate a CLLocationManager object
    var locationManager = CLLocationManager()
    
    var userAuthorizedLocationMonitoring = false
    @IBOutlet var homeTableView: UITableView!
    
    
    override func viewDidLoad() {

        itemIDs = Array(appDelegate.items.keys)
        dict_id_item = appDelegate.items
        super.viewDidLoad()
        /*
         The user can turn off location services on an iOS device in Settings.
         First, you must check to see of it is turned off or not.
         */
        if !CLLocationManager.locationServicesEnabled() {
            showAlertMessage(messageHeader: "Location Services Disabled!",
            messageBody: "Turn Location Services On in your device settings to be able to use location services!")
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemIDs.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let rowNumber = (indexPath as NSIndexPath).row
        let cell: HomeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Home Item Cell") as! HomeTableViewCell
        
        //Get item ID
        let id = itemIDs[rowNumber]
        
        //Get item
        var item = dict_id_item[id]
        
        // Set Item Thumbnail
        if item!.images[0] == ""{
            //cell.itemImageView!.image = UIImage(named: "noPosterImage.png")
            print("no thumbnail")
        }else{
            let url = URL(string: item!.images[0])
            let itemImageData = try? Data(contentsOf: url!)
            
            if let imageData = itemImageData {
                cell.itemImageView!.image = UIImage(data: imageData)
            } else {
                //cell.itemImageView!.image = UIImage(named: "noPosterImage.png")
                print("no thumbnail")
            }
        }
        
        cell.itemTitleLabel!.text = item!.title
        cell.itemPriceLabel!.text = String(describing: item!.price)
        //cell.itemPriceUnitLabel!.t
        // Configure the cell...

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
        
        let rowNumber = (indexPath as NSIndexPath).row
        
        //Get Item ID
        let id = itemIDs[rowNumber]
        
        // Obtain the item
        let item = dict_id_item[id]
        
        //Pass item to itemToPass
        itemToPass = item!
        
        performSegue(withIdentifier: "Show Item Details", sender: self)
        
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "Add Item", sender: self)
    }
    
    /*
     -------------------------
     MARK: - Prepare For Segue
     -------------------------
     */
    
    // This method is called by the system whenever you invoke the method performSegueWithIdentifier:sender:
    // You never call this method. It is invoked by the system.
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if segue.identifier == "Show Item Details" {
            
            // Obtain the object reference of the destination view controller
            let itemDetailsViewController: ItemDetailsViewController = segue.destination as! ItemDetailsViewController
            
            // Pass the data object to the downstream view controller object
            itemDetailsViewController.itemPassed = itemToPass
            itemDetailsViewController.navigationItem.title = itemToPass.title
            
        }else if segue.identifier == "Add Item"{
            
            
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
