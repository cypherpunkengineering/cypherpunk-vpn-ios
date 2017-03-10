//
//  TabletButtonCollectionViewCell.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 3/8/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit

class TabletButtonCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setStackViewAxis()
    }

    override func prepareForReuse() {
        setStackViewAxis()
    }
    
    private func setStackViewAxis() {
        if UIDevice.current.orientation.isLandscape {
            self.stackView.axis = .vertical
        }
        else {
            self.stackView.axis = .horizontal
        }
    }
}
