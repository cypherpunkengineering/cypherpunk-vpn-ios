//
//  ThemedSettingsTabButton.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedSettingsTabButton: UIButton {
    
    override func awakeFromNib() {
        configureView()
    }
    
    func configureView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .white:
            self.setTitleColor(UIColor.whiteThemeTextColor(), for: .normal)
        case .black:
            self.setTitleColor(UIColor.white, for: .normal)
        case .indigo:
            self.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
}
