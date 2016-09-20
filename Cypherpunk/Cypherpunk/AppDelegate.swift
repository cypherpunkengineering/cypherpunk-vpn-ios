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

let mainStore = Store<AppState>(
    reducer: AppReducer(),
    state: nil
)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        
        print("carrier: \(SpecificDataProvider.carrierName())")
        print("device name: \(SpecificDataProvider.deviceName())")
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: R.font.dosisSemiBold(size: 18.0)!,
            NSForegroundColorAttributeName: UIColor.whiteColor(),
        ]
        
        UINavigationBar.appearance().shadowImage = R.image.lineColor()
        
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: R.font.dosisMedium(size: 18.0)!,
            NSForegroundColorAttributeName: UIColor.whiteColor()
            ], for: .Normal)
        
        mainStore.dispatch(ThemeAction.ChangeToIndigo)
        VPNConfigurationCoordinator.start {
        }
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.gradient)
        
        DispatchQueue.main.async { [unowned self] in
            let firstOpen = R.storyboard.firstOpen.initialViewController()
            
            if mainStore.state.accountState.isLoggedIn == false {
                self.window?.rootViewController!.presentViewController(firstOpen!, animated: false, completion: nil)
            }
        }
        
        let config = Realm.Configuration(schemaVersion: 4, migrationBlock: {
            (migration, oldSchemaVersion) in
            if (oldSchemaVersion < 4) {
            }
        })
        
        Realm.Configuration.defaultConfiguration = config
        
        let realm = try! Realm()
        try! realm.write {
            if realm.objects(Region).count == 0 {
                realm.add(Region(name: "Tokyo1", ipAddress: "208.111.52.1"))
                realm.add(Region(name: "Tokyo2", ipAddress: "208.111.52.2"))
                realm.add(Region(name: "Honolulu", ipAddress: "199.68.252.203"))
            }
            
        }
        
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

