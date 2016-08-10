//
//  ThemedBackgroundView.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedBackgroundView: UIView {

    override func awakeFromNib() {
        reloadView()
    }
    
    func reloadView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .White:
            self.backgroundColor = UIColor(red: 242.0 / 255.0, green: 242.0 / 255.0 , blue: 242.0 / 255.0 , alpha: 1.0)
        case .Black:
            self.backgroundColor = UIColor.blackColor()
        }
    }
}
