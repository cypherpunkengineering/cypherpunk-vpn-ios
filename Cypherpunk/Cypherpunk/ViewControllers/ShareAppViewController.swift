//
//  ShareAppViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/11/07.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import FontAwesome_swift

class ShareAppViewController: UIViewController {

    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let iconSize = CGSize(width: 22, height: 22)
        facebookButton.setImage(UIImage.fontAwesomeIcon(name: .facebookOfficial, textColor: UIColor.white, size: iconSize).withRenderingMode(.alwaysOriginal), for: .normal)
        twitterButton.setImage(UIImage.fontAwesomeIcon(name: .twitter, textColor: UIColor.white, size: iconSize).withRenderingMode(.alwaysOriginal), for: .normal)
        emailButton.setImage(UIImage.fontAwesomeIcon(name: .envelopeO, textColor: UIColor.white, size: iconSize).withRenderingMode(.alwaysOriginal), for: .normal)

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
