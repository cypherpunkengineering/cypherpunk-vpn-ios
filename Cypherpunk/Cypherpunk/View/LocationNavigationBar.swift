//
//  LocationNavigationBar.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/10/05.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class LocationNavigationBar: UINavigationBar {
    override func awakeFromNib() {
        configureView()
    }
    
    func configureView() {
        self.isTranslucent = false
//        self.setBackgroundImage(R.image.locationBackgroung(), for: .default)
        self.barTintColor = UIColor.clear
        self.tintColor = UIColor.white
        self.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.locationHeaderTitleColorColor(),
            NSFontAttributeName: R.font.dosisBold(size: 16.0)!
        ]
    }

}
