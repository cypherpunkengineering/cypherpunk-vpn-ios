//
//  RateAppViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/09/30.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class RateAppViewController: UIViewController {

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
    @IBAction func rateNowAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func laterAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}