//
//  FirstOpenViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/26.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class FirstOpenViewController: UIViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }    
    @IBAction func startFreeNowAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
