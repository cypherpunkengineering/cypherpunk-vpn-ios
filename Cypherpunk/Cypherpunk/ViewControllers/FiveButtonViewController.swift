//
//  FiveButtonViewController.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 3/29/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit

class FiveButtonViewController: BaseButtonsViewController {
    @IBOutlet weak var cypherplayButtonView: UIView!
    @IBOutlet weak var fastestButtonView: MainButtonView!
    @IBOutlet weak var loc1ButtonView: MainButtonView!
    @IBOutlet weak var loc2ButtonView: MainButtonView!
    @IBOutlet weak var allLocButtonView: MainButtonView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updateLocationButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func updateLocationButtons() {
        if let loc1Option = vpnServerOptions[.Location1] {
            populateButtonViewWithLocationOption(option: loc1Option, view: loc1ButtonView)
        }
        
        if let loc2Option = vpnServerOptions[.Location2] {
            populateButtonViewWithLocationOption(option: loc2Option, view: loc2ButtonView)
        }
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
        else if tappedView == loc1ButtonView {
            connectToServer(vpnServerOptionType: .Location1)
        }
        else if tappedView == loc2ButtonView {
            connectToServer(vpnServerOptionType: .Location2)
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
