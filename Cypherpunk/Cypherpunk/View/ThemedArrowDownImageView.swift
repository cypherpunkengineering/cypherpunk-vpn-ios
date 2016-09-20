//
//  ThemedArrowDownImageView.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedArrowDownImageView: UIImageView {
    
    override func awakeFromNib() {
        configureView()
    }
    
    func configureView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .white:
            let image = UIImage(resource: R.image.arrow_down)?.withRenderingMode(.alwaysTemplate)
            self.image = image
            self.tintColor = UIColor.whiteThemeNavigationColor()
        case .black:
            let image = UIImage(resource: R.image.arrow_down)
            self.image = image
            self.tintColor = UIColor.lightGray
        case .indigo:
            let image = UIImage(resource: R.image.arrow_down)
            self.image = image
            self.tintColor = UIColor.white
        }
    }
}
