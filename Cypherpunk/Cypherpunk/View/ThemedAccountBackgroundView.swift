//
//  ThemedAccountBackgroundView.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedAccountBackgroundView: UIView {

    override func awakeFromNib() {
        configureView()
    }
    
    func configureView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .White:
            self.backgroundColor = UIColor.whiteThemeAccountCellColor()
        case .Black:
            self.backgroundColor = UIColor.whiteThemeTextColor()
        case .Indigo:
            self.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        }
    }
    
}
