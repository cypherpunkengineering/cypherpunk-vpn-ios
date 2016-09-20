//
//  ThemedChangeIPAddressButton.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedChangeIPAddressButton: UIButton {

    override func awakeFromNib() {
        let image = UIImage(resource: R.image.icon_refresh)?.withRenderingMode(.alwaysTemplate)
        self.setImage(image, for: .normal)
        
        configureView()
    }
    
    func configureView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .white:
            self.tintColor = UIColor.whiteThemeTextColor()
            self.setTitleColor(UIColor.whiteThemeTextColor(), for: .normal)
            self.borderColor = UIColor.whiteThemeTextColor()
        case .black:
            self.tintColor = UIColor.white
            self.setTitleColor(UIColor.white, for: .normal)
            self.borderColor = UIColor.white
        case .indigo:
            self.tintColor = UIColor.white
            self.setTitleColor(UIColor.white, for: .normal)
            self.borderColor = UIColor.white
        }
    }

}
