//
//  UserProfileViewController.swift
//  Cufflink
//
//  Created by Zuri Wong on 4/19/18.
//  Copyright © 2018 Zuri Wong. All rights reserved.
//

import UIKit
import CoreLocation

class UserProfileViewController: UIViewController{

    @IBOutlet var userImageView: UIButton!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userGeneralLocationLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    var ownerPassed: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameLabel.text! = ownerPassed.name()
        userImageView.layer.borderWidth = 1
        userImageView.layer.masksToBounds = false
        userImageView.layer.borderColor = UIColor.white.cgColor
        userImageView.layer.cornerRadius = userImageView.frame.height/2
        userImageView.clipsToBounds = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
