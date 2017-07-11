//
//  LocationCollectionViewCell.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 6/13/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit

class LocationCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var flagView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        self.locationLabel.textColor = UIColor.white
        self.flagView.alpha = 1.0
    }
    
    func showDisabledAppearance() {
        self.locationLabel.textColor = UIColor(white: 1.0, alpha: 0.5)
        self.flagView.alpha = 0.5
    }
    
    func displayRegion(region: Region) {
        self.flagView.image = UIImage(named: region.country.lowercased())
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            self.locationLabel.text = region.fullName
        }
        else {
            self.locationLabel.text = region.name
        }
        
        if !region.authorized {
            self.showDisabledAppearance()
        }
    }
}
