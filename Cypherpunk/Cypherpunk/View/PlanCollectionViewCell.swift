//
//  PlanCollectionViewCell.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 3/3/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit

class PlanCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var currentPlanLabel: UILabel!
    @IBOutlet weak var bestValueLabel: UILabel!
    @IBOutlet weak var planNameLabel: UILabel!
    @IBOutlet weak var monthlyCostLabel: UILabel!
    @IBOutlet weak var planView: UIView!
    @IBOutlet weak var moLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        prepareForReuse()
    }

    func setCurrentPlanColors() {
        // show the current plan flag and set colors
        self.currentPlanLabel.isHidden = false
        self.planView.backgroundColor = UIColor.clear
        self.planView.borderColor = UIColor.darkSlateBlue
        self.planNameLabel.textColor = UIColor.seafoamBlue
        self.monthlyCostLabel.textColor = UIColor.seafoamBlue
        self.moLabel.textColor = UIColor.seafoamBlue
    }
    
    func setBestValueColors() {
        // show the best value flag and set colors
        self.bestValueLabel.isHidden = false
        self.planView.borderColor = UIColor.nastyGreen
    }
    
    override func prepareForReuse() {
        self.currentPlanLabel.isHidden = true
        self.bestValueLabel.isHidden = true
        
        self.planView.backgroundColor = UIColor.white
        self.planView.borderColor = UIColor.niceBlue
        self.planNameLabel.textColor = UIColor.black
        self.monthlyCostLabel.textColor = UIColor.black
        self.moLabel.textColor = UIColor.black
    }
}
