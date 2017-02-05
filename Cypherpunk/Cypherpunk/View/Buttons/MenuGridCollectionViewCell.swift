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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        decoratorBgView.isHidden = true
        decoratorBgView.backgroundColor = UIColor.darkNavyBlue
        iconBgView.backgroundColor = UIColor.darkNavyBlue
        self.backgroundColor = UIColor.darkBlueGrey
        textLabel.textColor = UIColor.robinEggBlue
        textLabel.font = R.font.dosisRegular(size: 16.0)
    }
}
