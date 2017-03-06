//
//  PlanTableViewCell.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 3/3/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit

class PlanTableViewCell: UITableViewCell {
    @IBOutlet weak var currentPlanLabel: UILabel!
    @IBOutlet weak var bestValueLabel: UILabel!
    @IBOutlet weak var planNameLabel: UILabel!
    @IBOutlet weak var montlyCostLabel: UILabel!
    @IBOutlet weak var planView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
