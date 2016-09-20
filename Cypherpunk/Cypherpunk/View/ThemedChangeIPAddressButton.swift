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
        let image = UIImage(resource: R.image.icon_refresh)?.imageWithRenderingMode(.AlwaysTemplate)
        self.setImage(image, forState: .Normal)
        
        configureView()
    }
    
    func configureView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .White:
            self.tintColor = UIColor.whiteThemeTextColor()
            self.setTitleColor(UIColor.whiteThemeTextColor(), for: UIControlState())
            self.borderColor = UIColor.whiteThemeTextColor()
        case .Black:
            self.tintColor = UIColor.white
            self.setTitleColor(UIColor.white, for: UIControlState())
            self.borderColor = UIColor.white
        case .Indigo:
            self.tintColor = UIColor.white
            self.setTitleColor(UIColor.white, for: UIControlState())
            self.borderColor = UIColor.white            
        }
    }

}
