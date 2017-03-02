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
    @IBOutlet weak var usernameLabelButton: UIButton!
    @IBOutlet weak var subscriptionTypeLabel: UILabel!
    @IBOutlet weak var expirationLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mainStore.subscribe(self)
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
        
        usernameLabelButton.setTitle(accountState.mailAddress, for: .normal)
        
    }
}
