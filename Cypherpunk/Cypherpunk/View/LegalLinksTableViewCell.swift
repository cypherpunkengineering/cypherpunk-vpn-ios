//
//  LegalLinksTableViewCell.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 9/4/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit

class LegalLinksTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func tosClicked(_ sender: Any) {
        openUrl("https://cypherpunk.com/terms-of-service")
    }
    
    @IBAction func privacyPolicyClicked(_ sender: Any) {
        openUrl("https://cypherpunk.com/privacy-policy")
    }
    
    @IBAction func licenseClicked(_ sender: Any) {
        openUrl("https://cypherpunk.com/legal/license/ios")
    }
    
    private func openUrl(_ urlString: String) {
        let url = URL(string: urlString)
        UIApplication.shared.openURL(url!)
    }
}
