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
    
    // Obtain the object reference to the App Delegate object
    var appDelegate = UIApplication.shared.delegate as! AppDelegate

    var items: [Item] = []
    var itemId: String! = nil
    var userLocation = CLLocation()

    let tableViewRowHeight: CGFloat = 70.0

    // Instantiate a CLLocationManager object
    var locationManager = CLLocationManager()

    var userAuthorizedLocationMonitoring = false
    @IBOutlet var homeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the Add button on the right of the navigation bar to call the addCity method when tapped
        let addButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(HomeTableViewController.addItem(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        
        
        /*
         The user can turn off location services on an iOS device in Settings.
         First, you must check to see of it is turned off or not.
         */
        if !CLLocationManager.locationServicesEnabled() {
            showAlertMessage(messageHeader: "Location Services Disabled!",
            messageBody: "Turn Location Services On in your device settings to be able to use location services!")
            return
        }
        
        // We will use Option 1: Request user's authorization while the app is being used.
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied {
            userAuthorizedLocationMonitoring = false
        } else {
            userAuthorizedLocationMonitoring = true
        }
        
        if !userAuthorizedLocationMonitoring {
            
            // User does not authorize location monitoring
            showAlertMessage(messageHeader: "Authorization Denied!",
                             messageBody: "Unable to determine current location!")
            return
        }
       
        // Set the current view controller to be the delegate of the location manager object
        locationManager.delegate = self
        
        // Set the location manager's distance filter to kCLDistanceFilterNone implying that
        // a location update will be sent regardless of movement of the device
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        // Set the location manager's desired accuracy to be the best
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Start the generation of updates that report the user’s current location.
        // Implement the CLLocationManager Delegate Methods below to receive and process the location info.
        
        locationManager.startUpdatingLocation()
        
    }
    
    
    
    @IBAction func profileButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "Show Personal Profile", sender: self)
    }
    
    
    /*
     ------------------------------------------
     MARK: - CLLocationManager Delegate Methods
     ------------------------------------------
     */
    // Tells the delegate that a new location data is available
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        /*
         The objects in the given locations array are ordered with respect to their occurrence times.
         Therefore, the most recent location update is at the end of the array; hence, we access the last object.
         */
        let lastObjectAtIndex = locations.count - 1
        let currentLocation: CLLocation = locations[lastObjectAtIndex] as CLLocation
        
        // Obtain current location's coordinate
        userLocation = currentLocation
        
        // Stops the generation of location updates since we do not need it anymore
        manager.stopUpdatingLocation()
        
        // To make sure that it really stops updating the location, set its delegate to nil
        locationManager.delegate = nil
        
        
    }
    
    /*
     ------------------------
     MARK: - Location Manager
     ------------------------
     */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        // Stops the generation of location updates since error occurred
        manager.stopUpdatingLocation()
        
        // To make sure that it really stops updating the location, set its delegate to nil
        locationManager.delegate = nil
        
        showAlertMessage(messageHeader: "Unable to Locate You!",
                         messageBody: "An error occurred while trying to determine your location: \(error.localizedDescription)")
        return
    }

    override func viewWillAppear(_ animated: Bool) {
        items.removeAll()
        self.appDelegate.requestUrl("/items", nil) { (body, response) in
            let array = body as! [NSDictionary]
            let allItems = array.map { Item($0) }
            
            //only shows available items
            //NEEDS TO SORT BY DISTANCE FROM CURRENT USER!!!!
            for item in allItems {
                self.items.append(item)
                
//                self.appDelegate.requestUrl("/items/\(item.id)", nil){ (body, response) in
//                    var itemDetails = ItemDetails(body as! NSDictionary)
//
//                    if itemDetails.available{
//                        self.items.append(item)
//                    }
//                }
                
            }
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
    
    
    //Load Table View
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Home Item Cell", for: indexPath) as! HomeTableViewCell

        let item = items[indexPath.row]
        
        // Set Item Thumbnail
        cell.itemImageView!.image = item.thumbnail
        switch item.unitForPrice {
        case "perDay":
            cell.itemPriceUnitLabel.text! = "/ Day"
            break
        case "perHour":
            cell.itemPriceUnitLabel.text! = "/ Hour"
            break
        default:
            break
        }
        
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
     ---------------------------
     MARK: - Add New Item
     ---------------------------
     */
    
    // The addMovie method is invoked when the user taps the Add button created in viewDidLoad() above.
    @objc func addItem(_ sender: AnyObject) {
        
        // Perform the segue
        performSegue(withIdentifier: "Add Item", sender: self)
    }
    
    
    /*
     ---------------------------
     MARK: - Unwind Segue Method
     ---------------------------
     */
    @IBAction func unwindToHomeTableViewController(segue : UIStoryboardSegue) {
        if segue.identifier !=  "AddItem-Done"  {
            return
        }
        
        // Obtain the object reference of the source view controller
        let addItemViewController: AddItemViewController = segue.source as! AddItemViewController
        var images = [UIImage]()
        if addItemViewController.chosenImageOnePassed != nil{
            images.append(addItemViewController.chosenImageOnePassed!)
        }
        if addItemViewController.chosenImageTwoPassed != nil{
            images.append(addItemViewController.chosenImageTwoPassed!)
        }
        if addItemViewController.chosenImageThreePassed != nil{
            images.append(addItemViewController.chosenImageThreePassed!)
        }
        appDelegate.upload(images: images){(urls) in
            var postString = [
                "title": addItemViewController.itemTitleTextField.text!,
                "price": addItemViewController.itemPriceTextField.text!,
                "unitForPrice":addItemViewController.priceUnitSegmentControl.selectedSegmentIndex == 0 ? "perHour" : "perDay",
                "pictures": urls,
                "details": addItemViewController.itemDescriptionTextView.text!,
                "available": true
                ] as [String : Any]
            self.appDelegate.requestUrl("/items", postString){ (body, response) in
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
        if segue.identifier == "Show Item Details" {
            // Obtain the object reference of the destination view controller
            let itemDetailsViewController: ItemDetailsViewController = segue.destination as! ItemDetailsViewController

            // Pass the ID of the item to pull to the downstream view controller object
            itemDetailsViewController.itemId = itemId
            
            //Pass current User location to the downstream view controller object
            itemDetailsViewController.userLocationPassed = userLocation
            
        }else if segue.identifier == "Show Personal Profile"{
            // Obtain the object reference of the destination view controller
            let personalProfileViewController: PersonalProfileViewController = segue.destination as! PersonalProfileViewController
            
            //Pass current User location to the downstream view controller object
            personalProfileViewController.currentUserLocationPassed = userLocation
            
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
