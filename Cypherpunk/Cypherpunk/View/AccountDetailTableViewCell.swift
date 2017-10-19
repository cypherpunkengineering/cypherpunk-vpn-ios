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
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var userIconLabel: UILabel!
    @IBOutlet weak var keyIconLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mainStore.subscribe(self) { $0.select { state in state.accountState } }
        
        let iconColor = UIColor(red: 0, green: 142 / 255.0, blue: 140 / 255.0, alpha: 1)
        
        let userIconString = String.fontAwesomeIcon(name: .user)
        let keyIconString = String.fontAwesomeIcon(name: .key)
        
        let font = UIFont.fontAwesome(ofSize: 22.0)
        
        self.userIconLabel.textColor = iconColor
        self.keyIconLabel.textColor = iconColor
        
        self.userIconLabel.font = font
        self.keyIconLabel.font = font
        
        self.userIconLabel.text = userIconString
        self.keyIconLabel.text = keyIconString
        
        self.populateInfo()
        
        self.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        populateInfo()
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
    func newState(state: AccountState) {
        self.populateInfo()
    }
}
