//
//  FirstOpenViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/26.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class FirstOpenViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }    
    @IBAction func startFreeNowAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
