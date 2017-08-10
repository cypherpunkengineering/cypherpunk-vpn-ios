//
//  CypherplayCollectionViewCell.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 6/17/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit

class CypherplayCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var textLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let baseFont = R.font.dosisSemiBold(size: 18)!
        
        let attributedString = NSMutableAttributedString(string: "Fastest Location WITH CypherPlay™", attributes: [NSFontAttributeName: baseFont, NSForegroundColorAttributeName: UIColor(red: 213 / 255.0, green: 99 / 255.0, blue: 41 / 255.0, alpha: 1.0)])
        
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 210 / 255.0, green: 168 / 255.0, blue: 74 / 255.0, alpha: 1.0), range: NSRange(location: 0, length: 16))
        
        attributedString.addAttribute(NSFontAttributeName, value: R.font.dosisRegular(size: 11)!, range: NSRange(location: 17, length: 4))
        
        self.textLabel.attributedText = attributedString
    }
}
