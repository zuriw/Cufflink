//
//  AppDelegate.swift
//  Cufflink
//
//  Created by Zuri Wong on 2/22/18.
//  Copyright © 2018 Zuri Wong. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    // Instance variable to hold the object reference of a Dictionary object, the content of which is modifiable at runtime
    var dict_UserEmail_UserData: NSMutableDictionary = NSMutableDictionary()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        /*
         All application-specific and user data must be written to files that reside in the iOS device's
         Document directory. Nothing can be written into application's main bundle (project folder) because
         it is locked for writing after your app is published.
         
         The contents of the iOS device's Document directory are backed up by iTunes during backup of an iOS device.
         Therefore, the user can recover the data written by your app from an earlier device backup.
         
         The Document directory path on an iOS device is different from the one used for the iOS Simulator.
         
         To obtain the Document directory path, you use the NSSearchPathForDirectoriesInDomains function.
         However, this function was created originally for Mac OS, where multiple such directories could exist.
         Therefore, it returns an array of paths rather than a single path.
         
         For iOS, the resulting array's first element (index=0) contains the path to the Document directory.
         */
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectoryPath = paths[0] as String
        
        // Add the plist filename to the document directory path to obtain an absolute path to the plist filename
        let plistFilePathInDocumentDirectory = documentDirectoryPath + "/Users.plist"
        
        /*
         NSMutableDictionary manages an *unordered* collection of mutable (modifiable) key-value pairs.
         Instantiate an NSMutableDictionary object and initialize it with the contents of the Users.plist file.
         */
        let dictionaryFromFile: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: plistFilePathInDocumentDirectory)
        
        /*
         IF the optional variable dictionaryFromFile has a value, THEN
         Users.plist exists in the Document directory and the dictionary is successfully created
         ELSE read Users.plist from the application's main bundle.
         */
        if let dictionaryFromFileInDocumentDirectory = dictionaryFromFile {
            
            // Users.plist exists in the Document directory
            dict_UserEmail_UserData = dictionaryFromFileInDocumentDirectory
            
        } else {
            
            // CompaniesILike.plist does not exist in the Document directory; Read it from the main bundle.
            
            // Obtain the file path to the plist file in the mainBundle (project folder)
            let plistFilePathInMainBundle = Bundle.main.path(forResource: "Users", ofType: "plist")
            
            // Instantiate an NSMutableDictionary object and initialize it with the contents of the Users.plist file.
            let dictionaryFromFileInMainBundle: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: plistFilePathInMainBundle!)
            
            // Store the object reference into the instance variable
            dict_UserEmail_UserData = dictionaryFromFileInMainBundle!
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        /*
         "UIApplicationWillResignActiveNotification is posted when the app is no longer active and loses focus.
         An app is active when it is receiving events. An active app can be said to have focus.
         It gains focus after being launched, loses focus when an overlay window pops up or when the device is
         locked, and gains focus when the device is unlocked." [Apple]
         */
        
        // Define the file path to the CompaniesILike.plist file in the Document directory
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectoryPath = paths[0] as String
        
        // Add the plist filename to the document directory path to obtain an absolute path to the plist filename
        let plistFilePathInDocumentDirectory = documentDirectoryPath + "/Users.plist"
        
        // Write the NSMutableDictionary to the Users.plist file in the Document directory
        dict_UserEmail_UserData.write(toFile: plistFilePathInDocumentDirectory, atomically: true)
        
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

