//
//  YourItemTableViewCell.swift
//  Cufflink
//
//  Created by Christian Howe on 4/30/18.
//  Copyright © 2018 Zuri Wong. All rights reserved.
//

import UIKit

class YourItemTableViewCell: UITableViewCell {
    @IBOutlet var itemImageView: UIImageView!
    @IBOutlet var itemTitleLabel: UILabel!
    @IBOutlet var itemPriceLabel: UILabel!
    @IBOutlet var itemPriceUnitLabel: UILabel!
    @IBOutlet var availableLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
