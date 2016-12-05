//
//  EmailConfirmationViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/10/20.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import APIKit

class EmailConfirmationViewController: UIViewController {

    @IBOutlet weak var resendEmailButton: UIButton!
    
    var mailAddress: String!
    var password: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let attributes: [String: AnyObject] = [
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue as AnyObject,
            NSForegroundColorAttributeName: UIColor.white
        ]
        let resendEmailButtonAttribute = NSAttributedString(string: "Resend Email", attributes: attributes)
        resendEmailButton?.setAttributedTitle(resendEmailButtonAttribute, for: .normal)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
        startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        cancelTimer()
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

    @IBAction func backAction(_ sender: AnyObject) {
        let _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func resendAction(_ sender: Any) {
        let confirmation = ConfirmEmailRequest(email: mailAddress)
        Session.send(confirmation)
    }

    func update() {
        guard let session = mainStore.state.accountState.session else {
            return
        }
        let request = AccountStatusRequest(session: session)
        Session.send(request) { result in
            if case let .success(response) = result {
                if response.account.confirmed {
                    let region = RegionListRequest(session: session, accountType: response.account.type)
                    Session.send(region) { result in
                        if case .success = result {
                            var response = response
                            response.session = session
                            mainStore.dispatch(AccountAction.login(response: response))
                            
                            let destination = R.storyboard.walkthrough.instantiateInitialViewController()
                            self.navigationController?.pushViewController(destination!, animated: true)
                        }
                    }
                }
            }
        }
    }
    var timer: Timer! = nil
    func startTimer() {
        if timer == nil {
            self.timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(EmailConfirmationViewController.update), userInfo: nil, repeats: true)
            RunLoop.current.add(timer, forMode: .commonModes)
        }
    }
    
    func cancelTimer() {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
    

}
