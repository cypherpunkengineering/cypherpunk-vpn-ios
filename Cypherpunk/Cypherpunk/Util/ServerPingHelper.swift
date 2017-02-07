//
//  ServerPingHelper.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 2/6/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import GBPing
import RealmSwift

class ServerPingHelper : NSObject, GBPingDelegate {
    static var pingHandlers: [GBPing:PingHandler] = [:]
    
    static func updateLatencyForServers() {
        let realm = try! Realm()
        let servers = realm.objects(Region.self)
        
        for server in servers {
            print(server.ovHostname)
            let delegate = PingHandler(serverId: server.id)
            
            let ping = GBPing()
            ping.host = server.ovHostname
            ping.timeout = 1.0
            ping.delegate = delegate
            
            ping.setup({ (success, error) in
                if (success) {
                    ping.startPinging()
                    pingHandlers[ping] = delegate
                }
            })
        }
    }
}

class PingHandler : NSObject, GBPingDelegate {
    var rtts = [Double]()
    var serverId: String
    
    init(serverId: String) {
        self.serverId = serverId
        super.init()
    }
    
    func ping(_ pinger: GBPing!, didReceiveReplyWith summary: GBPingSummary!) {
        rtts.append(summary.rtt)
        
        print("\(serverId) - \(summary.rtt)")
        
        // stop the pinging after the 3rd ping and save the lowest latency
        if (summary.sequenceNumber == 2) {
            pinger.stop()
            ServerPingHelper.pingHandlers.removeValue(forKey: pinger)
            
            // evaluate all the rtts
            let minRtt = rtts.min()
            
            let realm = try! Realm()
            let region = realm.object(ofType: Region.self, forPrimaryKey: serverId)
            
            do {
                try realm.write {
                    region?.latencySeconds = minRtt!
                }
            } catch {
                print("Failed to udpate latency for \(serverId): \(error)")
            }
        }
    }
    
    // TODO: How should errors and timeouts be handled? Should the last known latency be removed from Realm?
//    func ping(_ pinger: GBPing!, didTimeoutWith summary: GBPingSummary!) {
//        
//    }
//    
//    func ping(_ pinger: GBPing!, didReceiveUnexpectedReplyWith summary: GBPingSummary!) {
//        
//    }
//    
//    func ping(_ pinger: GBPing!, didFailWithError error: Error!) {
//        
//    }
}
