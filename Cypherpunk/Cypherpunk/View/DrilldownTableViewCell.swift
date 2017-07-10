//
//  DrilldownTableViewCell.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 7/10/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit

class DrilldownTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.isUserInteractionEnabled = true
        self.selectionStyle = .gray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.isUserInteractionEnabled = true
        self.selectionStyle = .gray
    }
}
