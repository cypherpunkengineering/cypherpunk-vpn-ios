//
//  ThemedTableView.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

extension UIColor {
    class func whiteThemeTableViewBackgroundColor() -> UIColor {
        return UIColor(white: 229.0 / 255.0, alpha: 1.0)
    }
}

class ThemedTableView: UITableView {
    
    override func awakeFromNib() {
        configureView()
    }
}

extension UITableView {
    func configureView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .white:
            self.backgroundColor = UIColor.whiteThemeTableViewBackgroundColor()
            self.separatorColor = UIColor.whiteThemeSeparatorColor()
            self.tintColor = UIColor.whiteThemeIndicatorColor()
        case .black:
            self.backgroundColor = UIColor.black
            self.separatorColor = UIColor.whiteThemeTextColor()
        case .indigo:
            self.backgroundColor = UIColor.clear
            self.separatorColor = UIColor.white.withAlphaComponent(0.30)
        }
    }
}
