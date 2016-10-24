//
//  ConfigurationRootViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/08/18.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ConfigurationRootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let item = UIBarButtonItem(title: " ", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = item
        self.automaticallyAdjustsScrollViewInsets = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ConfigurationRootViewController {
    @IBAction func closeAction() {
        self.navigationController?.dismiss(animated: true)
    }
}
