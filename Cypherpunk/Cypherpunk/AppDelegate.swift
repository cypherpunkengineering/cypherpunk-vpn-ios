//
//  AppDelegate.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/06/17.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

import ReSwift
import SVProgressHUD
import RealmSwift
import APIKit
import SystemConfiguration.CaptiveNetwork
import ReachabilitySwift
import SwiftyStoreKit
import Firebase

let mainStore = Store<AppState>(
    reducer: appReducer.handleAction,
    state: nil
)

let appID = "XXXXX"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var reachability: Reachability!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white
        
        SwiftyStoreKit.completeTransactions() { products in
            for product in products {
                if product.needsFinishTransaction {
                    let upgradeRequest = UpgradeRequest(
                        session: mainStore.state.accountState.session!,
                        accountId: mainStore.state.accountState.mailAddress!,
                        planId: SubscriptionType.monthly.planId,
                        receipt: SwiftyStoreKit.localReceiptData!
                    )
                    Session.send(upgradeRequest) {
                        (result) in
                        switch result {
                        case .success:
                            print("purchased \(product.productId)!!")
                            mainStore.dispatch(AccountAction.upgrade(subscription: .monthly, expiredDate: Date()))
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            }
            
        }
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: R.font.dosisSemiBold(size: 18.0)!,
            NSForegroundColorAttributeName: UIColor.white,
        ]
        
        UINavigationBar.appearance().shadowImage = R.image.lineColor()
        
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: R.font.dosisMedium(size: 18.0)!,
            NSForegroundColorAttributeName: UIColor.white
            ], for: .normal)
        
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.gradient)
        
        let config = Realm.Configuration(schemaVersion: 6, migrationBlock: {
            (migration, oldSchemaVersion) in
            if (oldSchemaVersion < 6) {
            }
        })
        
        Realm.Configuration.defaultConfiguration = config
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            
            let vc: SlidingNavigationViewController! = R.storyboard.top_iPad.instantiateInitialViewController()
            let _ = vc.view // view instantiate trick

            self.window?.rootViewController = vc
            vc.fakeLaunchView.isHidden = true
            DispatchQueue.main.async { [unowned self] in
                if mainStore.state.accountState.isLoggedIn == false || mainStore.state.isInstalledPreferences == false {
                    vc.fakeLaunchView.isHidden = false
                    let firstOpen = R.storyboard.firstOpen_iPad.instantiateInitialViewController()
                    self.window?.rootViewController!.present(firstOpen!, animated: false, completion: {
                        vc.fakeLaunchView.isHidden = true
                    })
                } else {
                    mainStore.dispatch(RegionAction.setup)
                }
            }
            
        } else if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {

            let vc: SlidingNavigationViewController! = R.storyboard.top.instantiateInitialViewController()
            let _ = vc.view // view instantiate trick
            self.window?.rootViewController = vc
            vc.fakeLaunchView.isHidden = true

            DispatchQueue.main.async { [unowned self] in
                if mainStore.state.accountState.isLoggedIn == false || mainStore.state.isInstalledPreferences == false {
                    vc.fakeLaunchView.isHidden = false
                    let firstOpen = R.storyboard.firstOpen.instantiateInitialViewController()
                    self.window?.rootViewController!.present(firstOpen!, animated: false, completion: {
                        vc.fakeLaunchView.isHidden = true
                    })
                } else {
                    mainStore.dispatch(RegionAction.setup)
                }
            }
        }
        
        reachability = Reachability()
        
        reachability.whenReachable = {
            reachability in
            if reachability.isReachableViaWiFi {
                if let networkInfo = CNCopyCurrentNetworkInfo("en0" as CFString) as? NSDictionary {
                    if let ssid = networkInfo[kCNNetworkInfoKeySSID] {
                        let realm = try! Realm()
                        if realm.object(ofType: WifiNetworks.self, forPrimaryKey: ssid) == nil {
                            let wifi = WifiNetworks()
                            wifi.name = ssid as! String
                            
                            try! realm.write {
                                realm.add(wifi, update: true)
                            }
                            
                        }
                        
                    }
                }
            }
        }
        
        try! reachability.startNotifier()
        self.window?.makeKeyAndVisible()
        
        FIRApp.configure()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        if let networkInfo = CNCopyCurrentNetworkInfo("en0" as CFString) as? NSDictionary {
            if let ssid = networkInfo[kCNNetworkInfoKeySSID] {
                let realm = try! Realm()
                if realm.object(ofType: WifiNetworks.self, forPrimaryKey: ssid) == nil {
                    let wifi = WifiNetworks()
                    wifi.name = ssid as! String
                    
                    try! realm.write {
                        realm.add(wifi, update: true)
                    }
                    
                }
                
            }
        }
        
        if let _ = mainStore.state.accountState.vpnUsername, let _ = mainStore.state.accountState.vpnPassword {
            
            let failureBlock = {
                mainStore.dispatch(AccountAction.logout)
                let firstOpen: UIViewController!
                if UI_USER_INTERFACE_IDIOM() == .pad {
                    firstOpen = R.storyboard.firstOpen_iPad.instantiateInitialViewController()
                } else {
                    firstOpen = R.storyboard.firstOpen.instantiateInitialViewController()
                }
                self.window?.rootViewController!.present(firstOpen!, animated: false, completion: nil)
            }

            guard let session = mainStore.state.accountState.session else {
                return
            }
            let accountStatusRequest = AccountStatusRequest(session: session)
            Session.send(accountStatusRequest) { result in
                switch result {
                case .success(let response):
                    var response = response
                    response.session = session
                    
                    // Region Update
                    let region = RegionListRequest(session: response.session, accountType: response.account.type)
                    Session.send(region) { (result) in
                        switch result {
                        case .success:
                            mainStore.dispatch(RegionAction.setup)
                        case .failure:
                            break
                        }
                    }
                    
                    mainStore.dispatch(AccountAction.login(response: response))
                case .failure(.responseError(let error as ResponseError)):
                    if case let .unacceptableStatusCode(code) = error {
                        if code == 401 {
                            failureBlock()
                        }
                    }
                default:
                    break
                }
            }
       }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

