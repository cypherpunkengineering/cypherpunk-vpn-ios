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

let mainStore = Store<AppState>(
    reducer: AppReducer(),
    state: nil
)

let appID = "XXXXX"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: R.font.dosisSemiBold(size: 18.0)!,
            NSForegroundColorAttributeName: UIColor.white,
        ]
        
//        UINavigationBar.appearance().shadowImage = R.image.lineColor()
        
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: R.font.dosisMedium(size: 18.0)!,
            NSForegroundColorAttributeName: UIColor.white
            ], for: .normal)
        
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.gradient)
        
        let config = Realm.Configuration(schemaVersion: 4, migrationBlock: {
            (migration, oldSchemaVersion) in
            if (oldSchemaVersion < 4) {
            }
        })
        
        Realm.Configuration.defaultConfiguration = config
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            
            self.window?.rootViewController = R.storyboard.top_iPad.instantiateInitialViewController()

            DispatchQueue.main.async { [unowned self] in
                if mainStore.state.accountState.isLoggedIn == false {
                    let firstOpen = R.storyboard.firstOpen_iPad.instantiateInitialViewController()
                    self.window?.rootViewController!.present(firstOpen!, animated: false, completion: nil)
                } else {
                    let realm = try! Realm()
                    if let regionId = mainStore.state.regionState.lastSelectedRegionId, let region = realm.object(ofType: Region.self, forPrimaryKey: regionId) {
                        
                        mainStore.dispatch(RegionAction.changeRegion(regionId: region.id, name: region.regionName, serverIP: region.ipsecDefault, countryCode: region.countryCode, remoteIdentifier: region.ipsecHostname))
                    }

                    // Region Update
                    let request = RegionListRequest(session: mainStore.state.accountState.session!)
                    Session.send(request)
                }
            }

        } else if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            self.window?.rootViewController = R.storyboard.top.instantiateInitialViewController()

            DispatchQueue.main.async { [unowned self] in
                if mainStore.state.accountState.isLoggedIn == false {
                    let firstOpen = R.storyboard.firstOpen.instantiateInitialViewController()
                    self.window?.rootViewController!.present(firstOpen!, animated: false, completion: nil)
                } else {
                    let realm = try! Realm()
                    if let regionId = mainStore.state.regionState.lastSelectedRegionId, let region = realm.object(ofType: Region.self, forPrimaryKey: regionId) {
                        
                        mainStore.dispatch(RegionAction.changeRegion(regionId: region.id, name: region.regionName, serverIP: region.ipsecDefault, countryCode: region.countryCode, remoteIdentifier: region.ipsecHostname))
                    }

                    // Region Update
                    let request = RegionListRequest(session: mainStore.state.accountState.session!)
                    Session.send(request)
                }
            }
        }
        
        
        self.window?.makeKeyAndVisible()
        
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

    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

