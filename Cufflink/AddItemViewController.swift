//
//  AddItemViewController.swift
//  Cufflink
//
//  Created by Zuri Wong on 4/18/18.
//  Copyright © 2018 Zuri Wong. All rights reserved.
//

import UIKit

class AddItemViewController: UIViewController {

    @IBOutlet var itemTitleTextField: UITextField!
    @IBOutlet var itemPriceTextField: UITextField!
    @IBOutlet var addImageOneButton: UIButton!
    @IBOutlet var addImageTwoButton: UIButton!
    @IBOutlet var addImageThreeButton: UIButton!
    @IBOutlet var doneEditingButton: UIButton!
    @IBOutlet var itemDescriptionTextView: UITextView!
    @IBOutlet var priceUnitSegmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addImageOneButton.layer.borderWidth = 1
        addImageTwoButton.layer.borderWidth = 1
        addImageThreeButton.layer.borderWidth = 1
        doneEditingButton.layer.cornerRadius = 17
        doneEditingButton.clipsToBounds = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addImageOneButtonTapped(_ sender: UIButton) {
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
