//
//  InstallPreferencesViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/09/23.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class InstallPreferencesViewController: UIViewController {

    @IBOutlet weak var ioButtonImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ioButtonImageView.image = ioButtonImageView.image!.withRenderingMode(.alwaysTemplate)
        ioButtonImageView.tintColor = UIColor.whiteThemeIndicatorColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    @IBAction func install() {
        VPNConfigurationCoordinator.start {
        }
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