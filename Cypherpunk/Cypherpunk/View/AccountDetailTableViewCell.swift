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
        
        self.setBannerImage()
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
}

extension AccountDetailTableViewCell: StoreSubscriber {
    func newState(state: AppState) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        dateFormatter.locale = Locale.current
        
        let accountState = mainStore.state.accountState
        let dateString: String
        if let subscriptionType = accountState.subscriptionType {
            if let d = accountState.expiredDate {
                dateString = dateFormatter.string(from: d)
                expirationLabel.text = "\(subscriptionType.detailMessage) on \(dateString)"
            } else {
                expirationLabel.text = subscriptionType.detailMessage
            }
        } else {
            expirationLabel.text = ""
        }
        
        if self.subscriptionTypeLabel.text?.lowercased() != state.accountState.accountType?.lowercased() {
            self.subscriptionTypeLabel.text = state.accountState.accountType?.capitalized
        }
        
        usernameLabel.text = accountState.mailAddress
        
        self.setBannerImage()
    }
}
