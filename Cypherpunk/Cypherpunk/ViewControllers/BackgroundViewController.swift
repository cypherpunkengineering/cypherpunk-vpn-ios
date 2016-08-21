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
//        if let image = R.image.key_bg() {
//            self.view.backgroundColor = UIColor(patternImage: image)
//        }
        self.automaticallyAdjustsScrollViewInsets = false
        self.performSegueWithIdentifier(R.segue.backgroundViewController.signIn, sender: nil)
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let topColor = UIColor(red: 118.0 / 255.0, green: 168.0 / 255.0 , blue: 231.0 / 255.0 , alpha: 1.0)
        let bottomColor = UIColor(red: 3.0 / 255.0, green: 70.0 / 255.0 , blue: 152.0 / 255.0 , alpha: 1.0)
        let gradientColors: [CGColor] = [topColor.CGColor, bottomColor.CGColor]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.frame = self.view.layer.frame
        
        self.view.layer.insertSublayer(gradientLayer, atIndex: 0)
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
