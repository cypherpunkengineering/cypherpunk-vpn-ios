//
//  SevenButtonViewController.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 3/27/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit

class SevenButtonViewController: BaseButtonsViewController {
    @IBOutlet weak var cypherplayButtonView: UIView!
    @IBOutlet weak var fastestButtonView: MainButtonView!
    @IBOutlet weak var fastestUSButtonView: MainButtonView!
    @IBOutlet weak var fastestUKButtonView: MainButtonView!
    @IBOutlet weak var loc1ButtonView: MainButtonView!
    @IBOutlet weak var loc2ButtonView: MainButtonView!
    @IBOutlet weak var allLocButtonView: MainButtonView!
    
    @IBOutlet var buttons: Array<MainButtonView>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        updateLocationButtons()
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
    
    private func updateLocationButtons() {
        if let loc1Option = vpnServerOptions[.Location1] {
            if let server = loc1Option.getServer() {
                loc1ButtonView.iconView.image = UIImage(named: server.country.lowercased())
                
                let nameComponents = server.name.components(separatedBy: ",")
                loc1ButtonView.textLabel.text = nameComponents.first
            }
            else {
                loc1ButtonView.iconView.image = nil
                loc1ButtonView.textLabel.text = ""
            }
        }
        
        if let loc2Option = vpnServerOptions[.Location2] {
            if let server = loc2Option.getServer() {
                loc2ButtonView.iconView.image = UIImage(named: server.country.lowercased())
                
                let nameComponents = server.name.components(separatedBy: ",")
                loc2ButtonView.textLabel.text = nameComponents.first
            }
            else {
                loc2ButtonView.iconView.image = nil
                loc2ButtonView.textLabel.text = ""
            }
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
        else if tappedView == fastestUSButtonView {
            connectToServer(vpnServerOptionType: .FastestUS)
        }
        else if tappedView == fastestUKButtonView {
            connectToServer(vpnServerOptionType: .FastestUK)
        }
        else if tappedView == loc1ButtonView {
            connectToServer(vpnServerOptionType: .Location1)
        }
        else if tappedView == loc2ButtonView {
            connectToServer(vpnServerOptionType: .Location2)
        }
    }
}
