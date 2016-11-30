//
//  OneFinalStepViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/10/20.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class OneFinalStepViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func allowAction(_ sender: AnyObject) {
        FIRAnalyticsConfiguration.sharedInstance().setAnalyticsCollectionEnabled(true)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func dontAllowAction(_ sender: AnyObject) {
        FIRAnalyticsConfiguration.sharedInstance().setAnalyticsCollectionEnabled(false)
        self.dismiss(animated: true, completion: nil)
    }
}
