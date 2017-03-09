//
//  RegionTableViewCell.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/08/31.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class RegionTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var devLocationIconView: UIImageView!
    @IBOutlet weak var unavailableLocationIconView: UIImageView!
    
    @IBOutlet weak var premiumLocationIconView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureView()

    }
    
    func configureView() {
        self.titleLabel?.textColor = UIColor.white
        self.titleLabel?.font = R.font.dosisRegular(size: 16.0)
        self.backgroundColor = UIColor.clear
        self.tintColor = UIColor.white
    }
    
    func applySelectedStyle() {
        self.titleLabel?.textColor = UIColor.robinEggBlue
        self.titleLabel?.font = R.font.dosisBold(size: 16.0)
        self.backgroundColor = UIColor.darkBlueGrey
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        configureView()
    }
}
