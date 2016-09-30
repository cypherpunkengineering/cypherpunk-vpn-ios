//
//  ThemedModeTableViewCell.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedModeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var privacyModeView: UIView!
    @IBOutlet weak var speedModeView: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureView()
    }
    func configureView() {
        self.titleLabel?.textColor = UIColor.white
        self.descriptionView?.textColor = UIColor.white
        privacyModeView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        speedModeView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        self.backgroundColor = UIColor.white.withAlphaComponent(0.16)
    }

}
