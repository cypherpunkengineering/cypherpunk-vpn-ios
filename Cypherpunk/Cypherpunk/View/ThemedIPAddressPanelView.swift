//
//  ThemedIPAddressPanelView.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedIPAddressPanelView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var regionLabelButton: UIButton!
    
    override func awakeFromNib() {
        reloadView()
    }
    
    func reloadView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .White:
            self.titleLabel.textColor = UIColor.blackColor()
            self.regionLabelButton.setTitleColor(UIColor.whiteThemeTextColor(), forState: .Normal)
            self.backgroundColor = UIColor.whiteThemeAccountCellColor()
        case .Black:
            self.titleLabel.textColor = UIColor.whiteColor()
            self.regionLabelButton.setTitleColor(UIColor.whiteThemeSeparatorColor(), forState: .Normal)
            self.backgroundColor = UIColor.whiteThemeTextColor()
        }
    }
}
