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
        configureView()
    }
    
    func configureView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .white:
            self.titleLabel.textColor = UIColor.black
            self.regionLabelButton.setTitleColor(UIColor.whiteThemeTextColor(), for: .normal)
            self.backgroundColor = UIColor.whiteThemeAccountCellColor()
        case .black:
            self.titleLabel.textColor = UIColor.white
            self.regionLabelButton.setTitleColor(UIColor.whiteThemeSeparatorColor(), for: .normal)
            self.backgroundColor = UIColor.whiteThemeTextColor()
        case .indigo:
            self.titleLabel.textColor = UIColor.white
            self.regionLabelButton.setTitleColor(UIColor.white, for: .normal)
            self.backgroundColor = UIColor.whiteThemeAccountCellColor().withAlphaComponent(0.16)
        }
    }
}
