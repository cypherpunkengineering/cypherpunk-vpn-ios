//
//  ThemedSubTitleLabel.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedSubTitleLabel: UILabel {
    
    override func awakeFromNib() {
        configureView()
    }
    
    func configureView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .White:
            self.textColor = UIColor.whiteThemeNavigationColor()
        case .Black:
            self.textColor = UIColor.lightGrayColor()
        }
    }

}
