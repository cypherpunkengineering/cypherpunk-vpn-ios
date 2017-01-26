//
//  PopoverRootViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/10/25.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class PopoverRootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let barbutton = UIBarButtonItem(image: R.image.titleIconCancel(), style: .plain, target: self, action: #selector(closeAction))
        barbutton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = barbutton
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func closeAction() {
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - Navigation
}
