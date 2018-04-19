//
//  HomeTableViewController.swift
//  Cufflink
//
//  Created by Zuri Wong on 4/9/18.
//  Copyright © 2018 Zuri Wong. All rights reserved.
//

import UIKit

struct Item {
    let title: String
    var images: [String]
    let id: String
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


class HomeTableViewController: UITableViewController {

    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var items = [Item]()
    var session = URLSession()
    var itemToPass = Item(title: "", images: [], id: "", price: 0, priceUnit: "", details: "", Owner: User(name: "", email: "", image: "", phone: "", location: 0))
    //var itemIDToPass = 0
    let tableViewRowHeight: CGFloat = 70.0
    
    
    @IBOutlet var homeTableView: UITableView!
    
    
    override func viewDidLoad() {
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        items = appDelegate.items
        //var request = URLRequest(url: url)
        
        //request.httpMethod = "GET"
        session = appDelegate.session
        super.viewDidLoad()
        
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
        
        let rowNumber = (indexPath as NSIndexPath).row
        let cell: HomeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Home Item Cell") as! HomeTableViewCell
        
        // Set Item Thumbnail
        if items[rowNumber].images[0] == ""{
            //cell.itemImageView!.image = UIImage(named: "noPosterImage.png")
            print("no thumbnail")
        }else{
            let url = URL(string: items[rowNumber].images[0])
            let itemImageData = try? Data(contentsOf: url!)
            
            if let imageData = itemImageData {
                cell.itemImageView!.image = UIImage(data: imageData)
            } else {
                //cell.itemImageView!.image = UIImage(named: "noPosterImage.png")
                print("no thumbnail")
            }
        }
        
        cell.itemTitleLabel!.text = items[rowNumber].title
        cell.itemPriceLabel!.text = String(describing: items[rowNumber].price)
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
        // Obtain the item
        let item = items[rowNumber]
        //let VC = self.storyboard?.instantiateViewControllerWithIdentifier("ResetPasswordSuccessPopOver") as! ResetPasswordSuccessPopOverViewController
        
        let url = URL(string: "http://cufflink-api.now.sh/items/\(String(item.id))")
        let task = session.dataTask(with: url!) { (data,_,_) in
            guard let data = data else {return}
            do{
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                //print(json)
                if let myItem = json as? NSDictionary{
                    //print(array)
                    //let title = myItem["title"] as! String
                    var imageUrls = myItem["pictures"] as! NSArray
                    //let price = myItem["price"] as! NSNumber
                    //let id = myItem["_id"] as! String
                    //let priceUnit = myItem["unitForPrice"] as! String
                    var description = myItem["description"] as! String
                    var myOwner = NSDictionary()
                    myOwner = myItem["owner"] as! NSDictionary
                    var user = User(name: myOwner["name"] as! String, email: myOwner["email"] as! String, image: "", phone: "", location: myOwner["zipcode"] as! NSNumber)
                    self.itemToPass.images = imageUrls as! [String]
                    self.itemToPass.details = description
                    self.itemToPass.Owner = user
                    
                    let itemDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier: "ItemDetails") as! ItemDetailsViewController
                    itemDetailsViewController.itemPassed = self.itemToPass
                    itemDetailsViewController.navigationItem.title = self.itemToPass.title
                    itemDetailsViewController.modalPresentationStyle = .overCurrentContext
                    self.present(itemDetailsViewController, animated: true, completion: nil)

                }
                //performSegue(withIdentifier: "Show Item Details", sender: self.x)
            } catch {}
            
        }
        
        
        task.resume()
        
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
            
        }
    }

}
