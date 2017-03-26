//
//  UIDevice+Simulator.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 3/25/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

extension UIDevice {
    var isSimulator: Bool {
        #if IOS_SIMULATOR
            return true
        #else
            return false
        #endif
    }
}
