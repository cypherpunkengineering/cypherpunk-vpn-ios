//
//  ToggleTableViewCell.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 5/25/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit

class ToggleTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var toggle: UISwitch!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // remove any events that were added to the toggle
        self.toggle.removeTarget(nil, action: nil, for: .allEvents)
    }
}
