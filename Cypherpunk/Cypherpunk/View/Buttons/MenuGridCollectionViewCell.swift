//
//  MenuGridCollectionViewCell.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 2/4/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit

class MenuGridCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var decoratorBgView: UIView!
    @IBOutlet weak var decoratorView: UIImageView!
    @IBOutlet weak var iconBgView: UIView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            isSelected ? cellSelected() : cellDeselected()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        decoratorBgView.isHidden = true
        decoratorBgView.backgroundColor = UIColor.darkNavyBlue
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
        self.iconBgView.borderColor = UIColor.darkSlateBlue
        self.textLabel.textColor = UIColor.robinEggBlue
        self.textLabel.font = R.font.dosisRegular(size: 16.0)
    }
}
