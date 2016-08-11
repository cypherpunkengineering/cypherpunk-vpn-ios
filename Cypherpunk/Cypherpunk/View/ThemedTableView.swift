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
        reloadView()
    }
}

extension UITableView {
    func reloadView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .White:
            self.backgroundColor = UIColor.whiteThemeTableViewBackgroundColor()
            self.separatorColor = UIColor.whiteThemeSeparatorColor()
            self.tintColor = UIColor.whiteThemeIndicatorColor()
        case .Black:
            self.backgroundColor = UIColor.blackColor()
            self.separatorColor = UIColor.whiteThemeTextColor()
        }
    }
}