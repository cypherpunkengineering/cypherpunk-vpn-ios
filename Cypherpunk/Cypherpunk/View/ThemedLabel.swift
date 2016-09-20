//
//  ThemedLabel.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedLabel: UILabel {
    
    override func awakeFromNib() {
        configureView()
    }
    
    func configureView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .white:
            self.textColor = UIColor.whiteThemeTextColor()
        case .black:
            self.textColor = UIColor.white
        case .indigo:
            self.textColor = UIColor.blackThemeTextColor()
        }
    }
    
}
