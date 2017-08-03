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
    @IBOutlet weak var checkAgainButton: UIButton!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailPanelView: UIView!
    @IBOutlet weak var loadingAnimationView: LoadingAnimationView!
    
    @IBOutlet weak var checkEmailLabel: UILabel!
    @IBOutlet weak var confirmEmailLabel: UILabel!
    
    var mailAddress: String!
    
    var password: String!
    
    private var repeatCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.emailLabel.text = mailAddress
        
        let refreshString = String.fontAwesomeIcon(name: .refresh)
        let emailString = String.fontAwesomeIcon(name: .envelope)
        
        let fontAwesomeFont = UIFont.fontAwesome(ofSize: 16)
        let textFont = R.font.dosisRegular(size: 18)!
        let textColor = UIColor(red: 111 / 255.0, green: 133 / 255.0, blue: 137 / 255.0, alpha: 1.0)
        
        let checkAgainAttributedString = NSMutableAttributedString(string: refreshString + "   Check again", attributes: [NSFontAttributeName: textFont, NSForegroundColorAttributeName: textColor])
        
        checkAgainAttributedString.addAttributes([NSFontAttributeName: fontAwesomeFont], range: NSRange(location: 0, length: 1))
        self.checkAgainButton.setAttributedTitle(checkAgainAttributedString, for: .normal)
        
        
        let resendAttributedString = NSMutableAttributedString(string: emailString + "   Resend email", attributes: [NSFontAttributeName: textFont, NSForegroundColorAttributeName: textColor])
        
        resendAttributedString.addAttributes([NSFontAttributeName: fontAwesomeFont], range: NSRange(location: 0, length: 1))
        self.resendEmailButton.setAttributedTitle(resendAttributedString, for: .normal)
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
    
    @IBAction func checkAgainAction(_ sender: Any) {
        startTimer()
    }
    
    @IBAction func resendAction(_ sender: Any) {
        let confirmation = ConfirmEmailRequest(email: mailAddress)
        Session.send(confirmation)
    }

    func update() {
        if repeatCount > 4 {
            cancelTimer()
            return
        }
        
        guard let session = mainStore.state.accountState.session else {
            return
        }
        let request = AccountStatusRequest(session: session)
        Session.send(request) { result in
            if case let .success(response) = result {
                if response.account.confirmed {
                    mainStore.dispatch(AccountAction.login(response: response))
                    let region = RegionListRequest(session: session, accountType: response.account.type)
                    Session.send(region) { result in
                        if case .success = result {
                            var response = response
                            response.session = session
                            
                            let destination = R.storyboard.walkthrough.instantiateInitialViewController()
                            self.navigationController?.pushViewController(destination!, animated: true)
                        }
                    }
                }
            }
        }
        repeatCount += 1
    }
    var timer: Timer! = nil
    func startTimer() {
        if timer == nil {
            self.timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(EmailConfirmationViewController.update), userInfo: nil, repeats: true)
            RunLoop.current.add(timer, forMode: .commonModes)
        }
        
        UIView.animate(withDuration: 0.3) { 
            self.checkEmailLabel.layer.opacity = 1.0
            self.loadingAnimationView.layer.opacity = 1.0
            
            self.confirmEmailLabel.layer.opacity = 0.0
            self.resendEmailButton.layer.opacity = 0.0
            self.checkAgainButton.layer.opacity = 0.0
            self.resendEmailButton.layer.opacity = 0.0
        }
    }
    
    func cancelTimer() {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
        
        UIView.animate(withDuration: 0.3) { 
            self.checkEmailLabel.layer.opacity = 0.0
            self.loadingAnimationView.layer.opacity = 0.0
            
            self.confirmEmailLabel.layer.opacity = 1.0
            self.resendEmailButton.layer.opacity = 1.0
            self.checkAgainButton.layer.opacity = 1.0
            self.resendEmailButton.layer.opacity = 1.0
        }
        
        repeatCount = 0
    }
    

}
