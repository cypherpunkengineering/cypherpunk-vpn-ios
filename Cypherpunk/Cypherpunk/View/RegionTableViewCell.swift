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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureView()

    }
    
    func configureView() {
        self.titleLabel?.textColor = UIColor.white
        self.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        self.tintColor = UIColor.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


}
