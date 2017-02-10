//
//  RegionTableHeaderView.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 2/10/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

class RegionTableHeaderView : UIView {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var iconViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleViewLeadingSpaceConstraint: NSLayoutConstraint!
    
    func hideIconView() {
        iconViewWidthConstraint.constant = 0
        titleViewLeadingSpaceConstraint.constant = 0
    }
}
