//
//  LegalLinksView.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 9/4/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit

class LegalLinksView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

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
