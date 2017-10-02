//
//  MenuTableViewCell.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 3/1/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
//        self.accessoryType = .disclosureIndicator
    }
}
