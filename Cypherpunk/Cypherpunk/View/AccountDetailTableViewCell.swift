//
//  AccountDetailTableViewCell.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 3/1/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit
import ReSwift

class AccountDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var subscriptionTypeLabel: UILabel!
    @IBOutlet weak var expirationLabel: UILabel!
    @IBOutlet weak var userIconView: UIImageView!
    @IBOutlet weak var keyIconView: UIImageView!
    @IBOutlet weak var bannerImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mainStore.subscribe(self)
        
        let iconColor = UIColor(red: 0, green: 142 / 255.0, blue: 140 / 255.0, alpha: 1)
        
        self.userIconView.image = UIImage.fontAwesomeIcon(name: .user, textColor: iconColor, size: CGSize(width: 30, height: 30))
        
        self.keyIconView.image = UIImage.fontAwesomeIcon(name: .key, textColor: iconColor, size: CGSize(width: 30, height: 30))
        
        self.populateInfo()
        
        self.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.newState(state: AppState.getSharedState())
    }
    
    deinit {
        mainStore.unsubscribe(self)
    }
    
    fileprivate func setBannerImage() {
        if mainStore.state.accountState.isFreeAccount {
            self.bannerImageView.image = R.image.account_banner_free()
        }
        else {
            self.bannerImageView.image = R.image.account_banner_premium()
        }
    }
    
    fileprivate func populateInfo() {
        expirationLabel.text = AccountHelper.accountExpirationString()
        subscriptionTypeLabel.text = AccountHelper.accountTypeString()
        
        let accountState = mainStore.state.accountState
        usernameLabel.text = accountState.mailAddress
        
        self.setBannerImage()
    }
}

extension AccountDetailTableViewCell: StoreSubscriber {
    func newState(state: AppState) {
        self.populateInfo()
    }
}
