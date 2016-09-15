//
//  SpecificDataProvider.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/09/15.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation
import CoreTelephony

struct SpecificDataProvider {
    static func deviceName() -> String {
        let hardware = DeviceGuru.hardware()
        return hardware.name
    }
    static func carrierName() -> String? {
        let info = CTTelephonyNetworkInfo()
        let carrier = info.subscriberCellularProvider
        return carrier?.carrierName
    }
}

extension Hardware {
    var name: String {
        switch self {
        case .NOT_AVAILABLE:
            return "Not Available"
        case .IPHONE_2G, .IPHONE_3G, .IPHONE_3GS, .IPHONE_4, .IPHONE_4_CDMA:
            return "Not Supported"
        case .IPHONE_4S:
            return "iPhone4S"
        case .IPHONE_5, .IPHONE_5_CDMA_GSM:
            return "iPhone5"
        case .IPHONE_5C, .IPHONE_5C_CDMA_GSM:
            return "iPhone5c"
        case .IPHONE_5S, .IPHONE_5S_CDMA_GSM:
            return "iPhone5s"
        case .IPHONE_6:
            return "iPhone6"
        case .IPHONE_6_PLUS:
            return "iPhone6Plus"
        case .IPHONE_6S:
            return "iPhone6S"
        case .IPHONE_6S_PLUS:
            return "iPhone6SPlus"
        case .IPHONE_SE:
            return "iPhoneSE"
        default:
            return "Not Supported"
        }
    }
}