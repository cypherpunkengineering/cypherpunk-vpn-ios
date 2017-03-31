//
//  ThreeButtonViewController.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 3/30/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit

class ThreeButtonViewController: BaseButtonsViewController {
    @IBOutlet weak var cypherplayButtonView: UIView!
    @IBOutlet weak var fastestButtonView: MainButtonView!
    @IBOutlet weak var allLocButtonView: MainButtonView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        let tappedView = sender.view
        
        if tappedView == allLocButtonView {
            showServerList()
        }
        else if tappedView == cypherplayButtonView {
            connectToServer(vpnServerOptionType: .CypherPlay)
        }
        else if tappedView == fastestButtonView {
            connectToServer(vpnServerOptionType: .Fastest)
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
