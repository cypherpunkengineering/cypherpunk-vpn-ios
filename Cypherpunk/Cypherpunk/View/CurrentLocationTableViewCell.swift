//
//  CurrentLocationTableViewCell.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 2/15/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit

class CurrentLocationTableViewCell: UITableViewCell {
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var locationTextLabel: UILabel!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationTextLabelWidthConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
}
