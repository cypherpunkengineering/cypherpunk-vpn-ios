//
//  ControlSizeHelper.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 9/23/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import Foundation

class ControlSizeHelper {
    static let SWITCH_BASE_SIZE = CGSize(width: 115, height: 60)
    static let BASE_WIDTH: CGFloat = 350 // based on desktop app width
    static let IPAD_SWITCH_SIZE = CGSize(width: 172.5, height: 90)
    
    // base size is the size on an 320 point wide screen
    static func computeControlSize(baseSize: CGSize) -> CGSize {
        if UI_USER_INTERFACE_IDIOM() == .pad {
            return IPAD_SWITCH_SIZE
        }
        else {
            let scale = UIScreen.main.bounds.width / BASE_WIDTH
            return CGSize(width: baseSize.width * scale, height: baseSize.height * scale)
        }
    }
}
