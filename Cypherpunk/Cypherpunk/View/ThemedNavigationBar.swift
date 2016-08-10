//
//  ThemedNavigationBar.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedNavigationBar: UINavigationBar {
    
    override func awakeFromNib() {
        reloadView()
    }
    
    func reloadView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .White:
            self.tintColor = UIColor.whiteThemeNavigationColor()
            self.barTintColor = UIColor.whiteThemeTableViewBackgroundColor()
            self.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteThemeTextColor()]
        case .Black:
            self.barTintColor = UIColor.whiteColor()
            self.tintColor = UIColor.blackColor()
            self.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]

        }
    }
}
