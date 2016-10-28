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
        let barbutton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeAction))
        barbutton.setTitleTextAttributes([
            NSFontAttributeName: R.font.dosisMedium(size: 18.0)!,
            NSForegroundColorAttributeName: UIColor.goldenYellowColor()
            ], for: .normal)
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