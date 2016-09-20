//
//  IPAddress.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/06/24.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation
import NetworkExtension
import SystemConfiguration.CaptiveNetwork

enum NetworkInterface {
    case wifi
    case cellular
    case local
    
    var name: String {
        switch self {
        case .wifi:
            return "en0"
        case .cellular:
            return "pdp_ip0"
        case .local:
            return "lo0"
        }
    }
    
    var IPAddress: String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            
            // For each interface ...
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                let interface = ptr?.pointee
                
                // Check for IPv4 or IPv6 interface:
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    
                    // Check interface name:
                    if let name = String(validatingUTF8: (interface?.ifa_name)!) , name == self.name {
                        
                        // Convert interface address to a human readable string:
                        var addr = interface?.ifa_addr.pointee
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(&addr!, socklen_t((interface?.ifa_addr.pointee.sa_len)!),
                                    &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                        break
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        print("IPAddress: \(address)")
        return address
    }
    
    var SSID: String {
        var currentSSID: String = ""
        if #available(iOS 9.0, *) {
            for network in NEHotspotHelper.supportedNetworkInterfaces() {
                guard let network = network as? NEHotspotNetwork else {
                    continue
                }
                print(network.ssid)
            }
        } else {
            if let interfaces:CFArray? = CNCopySupportedInterfaces() {
                for i in 0..<CFArrayGetCount(interfaces){
                    let interfaceName: UnsafeRawPointer = CFArrayGetValueAtIndex(interfaces, i)
                    let rec = unsafeBitCast(interfaceName, to: AnyObject.self)
                    let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)" as CFString)
                    if unsafeInterfaceData != nil {
                        let interfaceData = unsafeInterfaceData! as Dictionary!
                        currentSSID = interfaceData["SSID"] as! String
                    }
                }
            }
        }
        return currentSSID
    }
    
}

