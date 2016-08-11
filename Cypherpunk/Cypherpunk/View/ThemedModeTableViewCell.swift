//
//  ThemedModeTableViewCell.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/10.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ThemedModeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var privacyModeView: UIView!
    @IBOutlet weak var speedModeView: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureView()
    }
    func configureView() {
        let themeState = mainStore.state.themeState
        switch themeState.themeType {
        case .White:
            self.titleLabel?.textColor = UIColor.whiteThemeTextColor()
            self.descriptionView?.textColor = UIColor.whiteThemeTextColor()
            privacyModeView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
            speedModeView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
            self.backgroundColor = UIColor.whiteColor()
        case .Black:
            self.titleLabel?.textColor = UIColor.whiteColor()
            self.descriptionView?.textColor = UIColor.whiteColor()
            privacyModeView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
            speedModeView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
            self.backgroundColor = UIColor.blackThemeCellBackgroundColor()
        }
    }

}
