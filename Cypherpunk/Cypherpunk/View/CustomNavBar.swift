//
//  CustomNavBar.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 10/25/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit

class CustomNavBar: UINavigationBar {
    
    // this nav bar is to be used for the nav bar with overhanging buttons, need to count the taps inside the buttons as being inside the nav bar
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in self.subviews {
            if subview.point(inside: point, with: event) {
                return true
            }
        }
        
        return super.point(inside: point, with: event)
    }
}
