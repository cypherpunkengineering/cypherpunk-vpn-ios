//
//  BackgroundViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/06/28.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class BackgroundViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let image = R.image.key_bg() {
            self.view.backgroundColor = UIColor(patternImage: image)
        }
        
        self.performSegueWithIdentifier(R.segue.backgroundViewController.signIn, sender: nil)
        
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