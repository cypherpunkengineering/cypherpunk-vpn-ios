//
//  ClearBackgroundSplitViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/10/07.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ClearBackgroundSplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clear
        self.preferredDisplayMode = .allVisible
        self.preferredPrimaryColumnWidthFraction = 250.0
        self.minimumPrimaryColumnWidth = 0.0
        self.maximumPrimaryColumnWidth = 250.0

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

}