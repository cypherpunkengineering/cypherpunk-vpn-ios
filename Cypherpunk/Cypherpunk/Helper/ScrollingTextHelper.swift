//
//  ScollingTextHelper.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 7/31/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import Foundation

class ScrollingTextHelper {
    static let PIPE_UPPER_TEXT = "x`8 0 # = v 7 mb\" | y 9 # 8 M } _ + kl $ #mn x -( }e f l]> ! 03 @jno x~`.xl ty }[sx k j"
    static let PIPE_LOWER_TEXT = "dsK 7 & [*h ^% u x 5 8 00 M< K! @ &6^d jkn 70 :93jx p0 bx, 890 Qw ;é \" >?7 9 3@ { 5x3 >"
    static let marqueeFont = R.font.dosisMedium(size: 11.0)!
    
    static func upperText() -> String {
        let maxWidth: CGFloat = maxScreenWidth()
        var upperTextWidth = PIPE_UPPER_TEXT.widthOfString(usingFont: ScrollingTextHelper.marqueeFont)
        var upperText: String = PIPE_UPPER_TEXT
        
        while upperTextWidth <= maxWidth {
            upperText.append(PIPE_UPPER_TEXT)
            upperTextWidth = upperText.widthOfString(usingFont: ScrollingTextHelper.marqueeFont)
        }
        
        return upperText
    }
    
    static func lowerText() -> String {
        let maxWidth: CGFloat = maxScreenWidth()
        var lowerTextWidth = PIPE_LOWER_TEXT.widthOfString(usingFont: ScrollingTextHelper.marqueeFont)
        var lowerText: String = PIPE_LOWER_TEXT
        
        while lowerTextWidth <= maxWidth {
            lowerText.append(PIPE_UPPER_TEXT)
            lowerTextWidth = lowerText.widthOfString(usingFont: ScrollingTextHelper.marqueeFont)
        }
        
        return lowerText
    }
    
    private static func maxScreenWidth() -> CGFloat {
        var maxWidth: CGFloat = 0
        if UI_USER_INTERFACE_IDIOM() == .pad {
            maxWidth = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        }
        else {
            maxWidth = UIScreen.main.bounds.width
        }
        
        return maxWidth
    }
}
