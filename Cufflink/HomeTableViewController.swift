//
//  HomeTableViewController.swift
//  Cufflink
//
//  Created by Zuri Wong on 4/9/18.
//  Copyright © 2018 Zuri Wong. All rights reserved.
//

import UIKit
import CoreLocation

class HomeTableViewController: UITableViewController, CLLocationManagerDelegate{
    var appDelegate = UIApplication.shared.delegate as! AppDelegate

    var items: [Item] = []
    var itemId: String! = nil

    let tableViewRowHeight: CGFloat = 70.0

    // Instantiate a CLLocationManager object
    var locationManager = CLLocationManager()

    var userAuthorizedLocationMonitoring = false
    @IBOutlet var homeTableView: UITableView!
    
    override func viewDidLoad() {
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

    override func viewWillAppear(_ animated: Bool) {
        self.appDelegate.requestUrl("/items", nil) { (body, response) in
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Home Item Cell", for: indexPath) as! HomeTableViewCell

        let item = items[indexPath.row]
        
        // Set Item Thumbnail
        cell.itemImageView!.image = item.thumbnail
        
        cell.itemTitleLabel!.text = item.title
        cell.itemPriceLabel!.text = String(item.price)
        //cell.itemPriceUnitLabel!.t

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
        //Get Item ID
        itemId = items[indexPath.row].id
        
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

            // Pass the ID of the item to pull to the downstream view controller object
            itemDetailsViewController.itemId = itemId
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
