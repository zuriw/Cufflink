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
    let available: Bool

    init(_ itemDictionary: NSDictionary) {
        let thumbnail = itemDictionary.value(forKey: "thumbnail")! as! String
        let url = URL(string: thumbnail)!
        let thumbnailData = try? Data(contentsOf: url)

        self.id = itemDictionary.value(forKey: "_id")! as! String
        self.title = itemDictionary.value(forKey: "title")! as! String
        self.price = (itemDictionary.value(forKey: "price")! as! NSNumber).doubleValue
        self.unitForPrice = itemDictionary.value(forKey: "unitForPrice")! as! String
        self.thumbnail = UIImage(data: thumbnailData!)!
        self.available = (itemDictionary.value(forKey: "available") as! Bool?) ?? true
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
    let available: Bool

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
        self.available = (itemDictionary.value(forKey: "available") as! Bool?) ?? true
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
    let items: [Item]

    init(_ itemDictionary: NSDictionary) {
        self.id = (itemDictionary.value(forKey: "_id") as! String?) ?? ""
        self.firstName = (itemDictionary.value(forKey: "firstName") as! String?) ?? ""
        self.lastName = (itemDictionary.value(forKey: "lastName") as! String?) ?? ""
        self.email = (itemDictionary.value(forKey: "email") as! String?) ?? ""
        self.profile = (itemDictionary.value(forKey: "profile") as! String?) ?? ""
        self.phone = (itemDictionary.value(forKey: "phone") as! String?) ?? ""
        self.location = (itemDictionary.value(forKey: "location") as! String?) ?? ""
        self.items = (itemDictionary.value(forKey: "items") as! [Item]?) ?? []
    }

    func name() -> String {
        return "\(self.firstName) \(self.lastName)"
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var token: String!
    var currentUser = User(NSDictionary())

    func login(email: String, password: String, completionHandler: @escaping (Bool) -> Void) {
        let url = URL(string: "https://cufflink-api.now.sh/login")
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
                    self.requestUrl("/me", nil) { (body, response) in
                        self.currentUser = User(body as! NSDictionary)
                    }
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

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

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

