//
//  ThemedMapImageView.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedMapImageView: UIImageView {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureView()
    }
    func configureView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .White:
            self.image = UIImage(resource: R.image.map_bk)
        case .Black:
            self.image = UIImage(resource: R.image.map_wh)
        }
    }
}
