//
//  HasSwitchThemedTableViewCell.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class HasSwitchThemedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
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
            self.backgroundColor = UIColor.white
        case .Black:
            self.titleLabel?.textColor = UIColor.white
            self.backgroundColor = UIColor.blackThemeCellBackgroundColor()
        case .Indigo:
            self.titleLabel?.textColor = UIColor.white
            self.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        }
    }
}
