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
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .White:
            self.titleLabel?.textColor = UIColor.whiteThemeTextColor()
            self.backgroundColor = UIColor.whiteColor()
        case .Black:
            self.titleLabel?.textColor = UIColor.whiteColor()
            self.backgroundColor = UIColor.blackThemeCellBackgroundColor()
        case .Indigo:
            self.titleLabel?.textColor = UIColor.whiteColor()
            self.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.16)
            self.tintColor = UIColor.whiteColor()
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


}
