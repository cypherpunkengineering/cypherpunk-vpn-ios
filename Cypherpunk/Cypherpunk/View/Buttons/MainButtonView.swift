//
//  MainButtonView.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 3/28/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit

class MainButtonView: UIView {
    @IBOutlet weak var iconBgView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    
    var isSelected: Bool = false {
        didSet {
            updateColors()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    private func updateColors() {
        if isSelected {
            self.backgroundColor = UIColor.darkNavyBlue
            self.iconBgView.backgroundColor = UIColor.darkBlueGrey
            self.iconBgView.borderColor = UIColor.darkCream
            self.textLabel.textColor = UIColor.darkCream
            self.textLabel.font = R.font.dosisBold(size: 16.0)
        }
        else {
            self.backgroundColor = UIColor.darkBlueGrey
            self.iconBgView.backgroundColor = UIColor.darkNavyBlue
            self.iconBgView.borderColor = UIColor.darkSlateBlue
            self.textLabel.textColor = UIColor.robinEggBlue
            self.textLabel.font = R.font.dosisRegular(size: 16.0)
        }
    }
    
//    private func cellSelected() {
//        self.backgroundColor = UIColor.darkNavyBlue
//        self.iconBgView.backgroundColor = UIColor.darkBlueGrey
//        self.iconBgView.borderColor = UIColor.darkCream
//        self.textLabel.textColor = UIColor.darkCream
//        self.textLabel.font = R.font.dosisBold(size: 16.0)
//    }
//    
//    private func cellDeselected() {
//        self.backgroundColor = UIColor.darkBlueGrey
//        self.iconBgView.backgroundColor = UIColor.darkNavyBlue
//        self.iconBgView.borderColor = UIColor.darkSlateBlue
//        self.textLabel.textColor = UIColor.robinEggBlue
//        self.textLabel.font = R.font.dosisRegular(size: 16.0)
//    }
}
