//
//  CypherPlayCollectionViewCell.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 2/1/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit

class CypherPlayCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var iconBgView: UIView!
    @IBOutlet weak var textLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override var isSelected: Bool {
        didSet {
            isSelected ? cellSelected() : cellDeselected()
        }
    }
    
    override func prepareForReuse() {
        cellDeselected()
    }

    private func cellSelected() {
        self.backgroundColor = UIColor.darkNavyBlue
        self.iconBgView.backgroundColor = UIColor.darkBlueGrey
        self.iconBgView.borderColor = UIColor.darkCream
        self.textLabel.textColor = UIColor.darkCream
        self.textLabel.font = R.font.dosisBold(size: 16.0)
    }
    
    private func cellDeselected() {
        self.backgroundColor = UIColor.darkBlueGrey
        self.iconBgView.backgroundColor = UIColor.darkNavyBlue
        self.iconBgView.borderColor = UIColor.robinEggBlue
        self.textLabel.textColor = UIColor.robinEggBlue
        self.textLabel.font = R.font.dosisRegular(size: 16.0)
    }
}
