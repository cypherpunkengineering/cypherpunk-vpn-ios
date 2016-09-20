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
        configureView()
    }
    
    func configureView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .white:
            self.tintColor = UIColor.whiteThemeNavigationColor()
            self.barTintColor = UIColor.whiteThemeTableViewBackgroundColor()
            self.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteThemeTextColor()]
        case .black:
            self.barTintColor = UIColor.white
            self.tintColor = UIColor.black
            self.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        case .indigo:
            self.isTranslucent = true
            self.setBackgroundImage(UIImage(), for: .default)
            self.barTintColor = UIColor.clear
            self.tintColor = UIColor.white
            self.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        }
    }
}
