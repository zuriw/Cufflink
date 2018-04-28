//
//  AppDelegate.swift
//  Cufflink
//
//  Created by Zuri Wong on 2/22/18.
//  Copyright © 2018 Zuri Wong. All rights reserved.
//

import UIKit

struct Item {
    let id: String
    let title: String
    let price: Double
    let unitForPrice: String
    let thumbnail: UIImage

    init(_ itemDictionary: NSDictionary) {
        let thumbnail = itemDictionary.value(forKey: "thumbnail")! as! String
        let url = URL(string: thumbnail)!
        let thumbnailData = try? Data(contentsOf: url)

        self.id = itemDictionary.value(forKey: "_id")! as! String
        self.title = itemDictionary.value(forKey: "title")! as! String
        self.price = (itemDictionary.value(forKey: "price")! as! NSNumber).doubleValue
        self.unitForPrice = itemDictionary.value(forKey: "unitForPrice")! as! String
        self.thumbnail = UIImage(data: thumbnailData!)!
    }
}

struct ItemDetails {
    let id: String
    let title: String
    let price: Double
    let unitForPrice: String
    let pictures: [UIImage]
    let details: String
    let owner: User

    init(_ itemDictionary: NSDictionary) {
        let imageArray = itemDictionary.value(forKey: "pictures")! as! [String]

        self.id = itemDictionary.value(forKey: "_id")! as! String
        self.title = itemDictionary.value(forKey: "title")! as! String
        self.price = (itemDictionary.value(forKey: "price")! as! NSNumber).doubleValue
        self.unitForPrice = itemDictionary.value(forKey: "unitForPrice")! as! String
        self.pictures = imageArray.map {
            let url = URL(string: $0)!
            let imageData = try? Data(contentsOf: url)
            return UIImage(data: imageData!)!
        }
        self.details = (itemDictionary.value(forKey: "details") as! String?) ?? "No details provided."
        self.owner = User(itemDictionary.value(forKey: "owner")! as! NSDictionary)
    }
}

struct User {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let profile: String
    let phone: String
    let location: String

    init(_ itemDictionary: NSDictionary) {
        self.id = itemDictionary.value(forKey: "_id")! as! String
        self.firstName = (itemDictionary.value(forKey: "firstName") as! String?) ?? ""
        self.lastName = (itemDictionary.value(forKey: "lastName") as! String?) ?? ""
        self.email = (itemDictionary.value(forKey: "email") as! String?) ?? ""
        self.profile = (itemDictionary.value(forKey: "profile") as! String?) ?? ""
        self.phone = (itemDictionary.value(forKey: "phone") as! String?) ?? ""
        self.location = (itemDictionary.value(forKey: "location") as! String?) ?? ""
    }

    func name() -> String {
        return "\(self.firstName) \(self.lastName)"
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var token: String!
   // var currentUser = User(NSDictionary())

    func login(email: String, password: String, completionHandler: @escaping (Bool) -> Void) {
        let url = URL(string: "https://cufflink-api.now.sh/login")
//        self.requestUrl("/me", nil) { (body, response) in
//            self.currentUser = User(body as! NSDictionary)
//        }
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        // Setting the content-type as JSON
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //Setting the result content-type as JSON
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let postString = [
            "email": email,
            "password": password
        ] as [String: String]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postString, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { (data, response: URLResponse?, error: Error?) in
            let httpResponse = response! as! HTTPURLResponse
            if (httpResponse.statusCode == 200) {
                do {
                    let values = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: String]
                    self.token = values["token"]
                    
                    DispatchQueue.main.async {
                        completionHandler(true)
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            } else if httpResponse.statusCode == 400 {
                DispatchQueue.main.async {
                    completionHandler(false)
                }
            } else {
                print(httpResponse)
                print(String(data: data!, encoding: .utf8)!)
            }
        }
        task.resume()
    }
    
    func signUp(firstName: String, lastName: String, phone: String, email: String, location: String, password: String, completionHandler: @escaping (Bool) -> Void) {
        let url = URL(string: "https://cufflink-api.now.sh/signup")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        // Setting the content-type as JSON
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //Setting the result content-type as JSON
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let postString = [
            "firstName": firstName,
            "lastName": lastName,
            "phone": phone,
            "email": email,
            "location": location,
            "password": password
            ] as [String: String]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postString, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response: URLResponse?, error: Error?) in
            let httpResponse = response! as! HTTPURLResponse
            if (httpResponse.statusCode == 200) { //SUCCESS! good to go!
                DispatchQueue.main.async {
                    completionHandler(true)
                }
            } else if httpResponse.statusCode == 400 { //Missing information or already signed up
                DispatchQueue.main.async {
                    completionHandler(false)
                }
            } else {
                print(httpResponse)
                print(String(data: data!, encoding: .utf8)!)
            }
        }
        task.resume()
    }

    func requestUrl(_ path: String, _ body: Any?, completionHandler: @escaping (Any, HTTPURLResponse) -> Void) {
        let url = URL(string: "https://cufflink-api.now.sh\(path)")

        var request = URLRequest(url: url!)
        request.httpMethod = body == nil ? "GET" : "POST"
        // Setting the content-type as JSON
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //Setting the result content-type as JSON
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        if self.token != nil {
            request.addValue(self.token, forHTTPHeaderField: "token")
        }

        do {
            if body != nil {
                request.httpBody = try JSONSerialization.data(withJSONObject: body!, options: [])
            }

            let task = URLSession.shared.dataTask(with: request) { (data, response: URLResponse?, error: Error?) in
                let httpResponse = response! as! HTTPURLResponse
                DispatchQueue.main.async {
                    do {
                        let values = try JSONSerialization.jsonObject(with: data!, options: [])
                        completionHandler(values, httpResponse)
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
            task.resume()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        /*
//         All application-specific and user data must be written to files that reside in the iOS device's
//         Document directory. Nothing can be written into application's main bundle (project folder) because
//         it is locked for writing after your app is published.
//
//         The contents of the iOS device's Document directory are backed up by iTunes during backup of an iOS device.
//         Therefore, the user can recover the data written by your app from an earlier device backup.
//
//         The Document directory path on an iOS device is different from the one used for the iOS Simulator.
//
//         To obtain the Document directory path, you use the NSSearchPathForDirectoriesInDomains function.
//         However, this function was created originally for Mac OS, where multiple such directories could exist.
//         Therefore, it returns an array of paths rather than a single path.
//
//         For iOS, the resulting array's first element (index=0) contains the path to the Document directory.
//         */
//
//        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//        let documentDirectoryPath = paths[0] as String
//
//        // Add the plist filename to the document directory path to obtain an absolute path to the plist filename
//        let plistFilePathInDocumentDirectory = documentDirectoryPath + "/Users.plist"
//
//        /*
//         NSMutableDictionary manages an *unordered* collection of mutable (modifiable) key-value pairs.
//         Instantiate an NSMutableDictionary object and initialize it with the contents of the Users.plist file.
//         */
//        let dictionaryFromFile: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: plistFilePathInDocumentDirectory)
//
//        /*
//         IF the optional variable dictionaryFromFile has a value, THEN
//         Users.plist exists in the Document directory and the dictionary is successfully created
//         ELSE read Users.plist from the application's main bundle.
//         */
//        if let dictionaryFromFileInDocumentDirectory = dictionaryFromFile {
//
//            // Users.plist exists in the Document directory
//            dict_UserEmail_UserData = dictionaryFromFileInDocumentDirectory
//
//        } else {
//
//            // CompaniesILike.plist does not exist in the Document directory; Read it from the main bundle.
//
//            // Obtain the file path to the plist file in the mainBundle (project folder)
//            let plistFilePathInMainBundle = Bundle.main.path(forResource: "Users", ofType: "plist")
//
//            // Instantiate an NSMutableDictionary object and initialize it with the contents of the Users.plist file.
//            let dictionaryFromFileInMainBundle: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: plistFilePathInMainBundle!)
//
//            // Store the object reference into the instance variable
//            dict_UserEmail_UserData = dictionaryFromFileInMainBundle!
//        }
        
//        let url = URL(string: "http://cufflink-api.now.sh/items")
//        let task = session.dataTask(with: url!) { (data,_,_) in
//            guard let data = data else {return}
//            do{
//                let json = try JSONSerialization.jsonObject(with: data, options: [])
//                //print(json)
//                if let array = json as? NSArray{
//                    //print(array)
//
//                    let dict = array[0] as! NSDictionary
//                    let id = dict["_id"] as! String
//
//                    //Get Item Details from id
//                    self.requestUrl("http://cufflink-api.now.sh/items/\(String(id))", nil) { (data,_,_) in
//                        guard let data = data else {return}
//                        do{
//                            let json = try JSONSerialization.jsonObject(with: data, options: [])
//                            if let myItem = json as? NSDictionary{
//                                let title = myItem["title"] as! String
//                                let imageUrls = myItem["pictures"] as! NSArray
//                                let price = myItem["price"] as! NSNumber
//                                let id = myItem["_id"] as! String
//                                let priceUnit = myItem["unitForPrice"] as! String
//                                let description = myItem["description"] as! String
//                                var myOwner = NSDictionary()
//                                myOwner = myItem["owner"] as! NSDictionary
//                                let user = User(name: myOwner["name"] as! String, email: myOwner["email"] as! String, image: "", phone: "", location: myOwner["zipcode"] as! NSNumber)
//
//                                let item = Item(title: title, images: imageUrls as! [String], id: id, available: false, price: price, priceUnit: priceUnit, details: description, Owner: user)
//                                self.items[id] = item
//
//                            }
//                        } catch {}
//
//                    }
//                }
//
//            } catch {}
//
//        }
//        task.resume()
//
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        /*
         "UIApplicationWillResignActiveNotification is posted when the app is no longer active and loses focus.
         An app is active when it is receiving events. An active app can be said to have focus.
         It gains focus after being launched, loses focus when an overlay window pops up or when the device is
         locked, and gains focus when the device is unlocked." [Apple]
         */

//        // Define the file path to the CompaniesILike.plist file in the Document directory
//        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//        let documentDirectoryPath = paths[0] as String
//
//        // Add the plist filename to the document directory path to obtain an absolute path to the plist filename
//        let plistFilePathInDocumentDirectory = documentDirectoryPath + "/Users.plist"
//
//        // Write the NSMutableDictionary to the Users.plist file in the Document directory
//        dict_UserEmail_UserData.write(toFile: plistFilePathInDocumentDirectory, atomically: true)
        
        /*
         The flag "atomically" specifies whether the file should be written atomically or not.
         
         If flag atomically is TRUE, the dictionary is first written to an auxiliary file, and
         then the auxiliary file is renamed to path plistFilePathInDocumentDirectory.
         
         If flag atomically is FALSE, the dictionary is written directly to path plistFilePathInDocumentDirectory.
         This is a bad idea since the file can be corrupted if the system crashes during writing.
         
         The TRUE option guarantees that the file will not be corrupted even if the system crashes during writing.
         */
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

