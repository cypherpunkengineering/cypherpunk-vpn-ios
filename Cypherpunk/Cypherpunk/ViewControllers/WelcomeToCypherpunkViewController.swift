//
//  WelcomeToCypherpunkViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/10/20.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

import APIKit
import RealmSwift
import SVProgressHUD
import ReSwift


class WelcomeToCypherpunkViewController: UIViewController, StoreSubscriber, TTTAttributedLabelDelegate {
    
    fileprivate enum State {
        case getStarted
        case signUp
        case logIn
    }
    
    @IBOutlet weak var topSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var inputField: ThemedTextField!
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var loadingAnimationView: LoadingAnimationView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var termOfServiceAndPrivacyPolicyView: UIView!
    @IBOutlet weak var termsLabel: TTTAttributedLabel!
    
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var illustrationView: UIImageView!
    fileprivate var email: String = ""
    
    fileprivate var state: State = .getStarted
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let attributes: [String: AnyObject] = [
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue as AnyObject,
            NSForegroundColorAttributeName: #colorLiteral(red: 0.5212592483, green: 0.7715299726, blue: 0.8048351407, alpha: 1)
        ]
        let forgotPasswordAttributed = NSAttributedString(string: "Forgot Password?", attributes: attributes)
        forgotPasswordButton?.setAttributedTitle(forgotPasswordAttributed, for: .normal)
        
        actionButton.layer.cornerRadius = 5.0
        actionButton.layer.shadowOpacity = 1.0
        actionButton.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        actionButton.layer.shadowRadius = 5.0
        actionButton.layer.shadowColor = UIColor.darkBlueGreyTwo.cgColor
        
        actionButton.setBackgroundColor(color: UIColor.burntSienna, forState: .normal)
        
        actionButton.setBackgroundColor(color: UIColor.tacao, forState: .highlighted)
        
        actionButton.setBackgroundColor(color: UIColor.burntSienna.darkerColor(percent: 0.2), forState: .disabled)
        
        actionButton.layer.masksToBounds = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        loadingAnimationView.startAnimation()
        
        self.state = .getStarted
        self.welcomeLabel.text = "Please enter your email to begin"
        setPlaceholderText("Type your email", color: UIColor.greenyBlue)
        self.inputField.text = self.email
        
        
        self.actionButton.isEnabled = isValidMailAddress(inputField.text!)
        self.actionButton.setTitle("Get Started", for: .normal)
        self.actionButton.setTitleColor(UIColor.lightGray, for: .disabled)
        self.inputField.isSecureTextEntry = false
        self.inputField.keyboardType = .emailAddress
        self.inputField.returnKeyType = UIReturnKeyType.next
        self.welcomeLabel.alpha = 1.0
        self.inputField.alpha = 1.0
        self.actionButton.alpha = 1.0
        self.backButton.alpha = 0.0
        self.forgotPasswordButton.alpha = 0.0
        self.termOfServiceAndPrivacyPolicyView.alpha = 0.0
        self.loadingAnimationView.alpha = 0.0
        
        // Build the ToS and Privacy disclaimer label text
        self.termsLabel.numberOfLines = 0;
        let string = "By signing up, you agree to our Terms of Service and confirm that you have read the Privacy Policy."
        self.termsLabel.text = string
        self.termsLabel.linkAttributes = [kCTForegroundColorAttributeName as AnyHashable : #colorLiteral(red: 0.6228144169, green: 0.9941515326, blue: 0.9880328774, alpha: 1), kCTUnderlineStyleAttributeName as AnyHashable : NSUnderlineStyle.styleSingle.rawValue, kCTUnderlineColorAttributeName as AnyHashable : #colorLiteral(red: 0.6228144169, green: 0.9941515326, blue: 0.9880328774, alpha: 1)]
        self.termsLabel.activeLinkAttributes = [kCTForegroundColorAttributeName as AnyHashable : #colorLiteral(red: 0.1723374724, green: 0.3221004605, blue: 0.3453483284, alpha: 1), kCTUnderlineStyleAttributeName as AnyHashable : NSUnderlineStyle.styleSingle.rawValue, kCTUnderlineColorAttributeName as AnyHashable : #colorLiteral(red: 0.1723374724, green: 0.3221004605, blue: 0.3453483284, alpha: 1)]
        let tosRange = NSMakeRange(32, 16)
        self.termsLabel.addLink(to: URL(string: "https://cypherpunk.com/terms-of-service"), with: tosRange)
        let privacyPolicyRange = NSMakeRange(84, 14)
        self.termsLabel.addLink(to: URL(string: "https://cypherpunk.com/privacy-policy"), with: privacyPolicyRange)
        self.termsLabel.delegate = self

        mainStore.subscribe(self)
        registerKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainStore.unsubscribe(self)
        removeKeyboardNotification()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let destination = destination as? EmailConfirmationViewController {
            destination.mailAddress = email
            destination.password = inputField.text
        }
        if let destination = destination as? ResetYourPasswordViewController {
            destination.mailAddress = email
        }

    }
    
    // TTTAttributedLabelDelegate - handle the ToS and Privacy links
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        UIApplication.shared.openURL(url)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func startAnimation() {
        UIView.animate(withDuration: 0.3, animations: {
            self.welcomeLabel.alpha = 0.0
            self.inputField.alpha = 1.0
            self.actionButton.alpha = 0.0
            self.loadingAnimationView.alpha = 1.0
            self.backButton.alpha = 0.0
            self.forgotPasswordButton.alpha = 0.0
            self.termOfServiceAndPrivacyPolicyView.alpha = 0.0

            switch self.state {
            case .getStarted:
                break
            case .logIn:
                self.welcomeLabel.text = "Please enter your password to login"
                self.setPlaceholderText("Type your password", color: UIColor.white)
                self.actionButton.setTitle("Log In", for: .normal)
                self.inputField.isSecureTextEntry = true
                self.inputField.returnKeyType = UIReturnKeyType.send
//                self.inputField.becomeFirstResponder()
            case .signUp:
                self.welcomeLabel.text = "Please create a password to begin"
                self.setPlaceholderText("Type your password", color: UIColor.white)
                self.actionButton.setTitle("Sign Up", for: .normal)
                self.inputField.isSecureTextEntry = true
                self.inputField.returnKeyType = UIReturnKeyType.send
//                self.inputField.becomeFirstResponder()
            }

            })
        { (finished) in
            if finished {
                DispatchQueue.main.async {
                    switch self.state {
                    case .getStarted:
                        self.welcomeLabel.text = "Please enter your email to begin"
                        self.setPlaceholderText("Type your email", color: UIColor.greenyBlue)
                        self.inputField.text = self.email
                        self.actionButton.isEnabled = isValidMailAddress(self.inputField.text!)
                        self.actionButton.setTitle("Get Started", for: .normal)
                        self.inputField.keyboardType = .emailAddress
                        self.inputField.isSecureTextEntry = false
                        self.inputField.returnKeyType = UIReturnKeyType.next
                        
                        UIView.animate(withDuration: 0.3, animations: {
                            self.welcomeLabel.alpha = 1.0
                            self.inputField.alpha = 1.0
                            self.actionButton.alpha = 1.0
                            self.loadingAnimationView.alpha = 0.0
                        })
                    case .logIn:
                        self.welcomeLabel.text = "Please enter your password to login"
                        self.setPlaceholderText("Type your password", color: UIColor.white)
                        self.actionButton.isEnabled = false
                        self.actionButton.setTitle("Log In", for: .normal)

                        self.inputField.isSecureTextEntry = true
                        self.inputField.returnKeyType = UIReturnKeyType.send
//                        self.inputField.becomeFirstResponder()
                        UIView.animate(withDuration: 0.3, animations: {
                            self.welcomeLabel.alpha = 1.0
                            self.inputField.alpha = 1.0
                            self.actionButton.alpha = 1.0
                            self.loadingAnimationView.alpha = 0.0
                            self.backButton.alpha = 1.0
                            self.forgotPasswordButton.alpha = 1.0
                            
                        })
                    case .signUp:
                        self.setPlaceholderText("Type your password", color: UIColor.white)
                        self.actionButton.isEnabled = false
                        self.actionButton.setTitle("Sign Up", for: .normal)
                        
                        self.inputField.isSecureTextEntry = true
                        self.inputField.returnKeyType = UIReturnKeyType.send
//                        self.inputField.becomeFirstResponder()
                        
                        self.welcomeLabel.text = "Please create a password to begin"

                        UIView.animate(withDuration: 0.3, animations: {
                            self.welcomeLabel.alpha = 1.0
                            self.inputField.alpha = 1.0
                            self.actionButton.alpha = 1.0
                            self.loadingAnimationView.alpha = 0.0
                            self.backButton.alpha = 1.0
                            self.termOfServiceAndPrivacyPolicyView.alpha = 1.0
                        })
                    }
                }
            }
        }
    }
    
    @IBAction func startAction() {
        inputField.resignFirstResponder()
        switch state {
        case .getStarted:
            UIView.animate(withDuration: 0.3, animations: {
                self.welcomeLabel.alpha = 0.0
                self.inputField.alpha = 0.0
                self.actionButton.alpha = 0.0
                self.loadingAnimationView.alpha = 1.0
                self.backButton.alpha = 0.0
                self.forgotPasswordButton.alpha = 0.0
            })
            { (finished) in
                if finished {
                    if let email = self.inputField.text, isValidMailAddress(email) {
                        let identifyRequest = IdentifyEmailRequest(email: email)
                        Session.send(identifyRequest) {
                            (result) in
                            switch result {
                            case .success(let isAlreadyRegistered):
                                self.email = email
                                if isAlreadyRegistered {
                                    self.state = .logIn
                                } else {
                                    self.state = .signUp
                                }
                            case .failure(let error):
                                print(error)
                                self.state = .getStarted
                            }
                            self.startAnimation()
                        }
                    }else {
                        self.state = .getStarted
                        self.startAnimation()
                    }
                }
            }

        case .signUp:
            UIView.animate(withDuration: 0.3, animations: {
                self.welcomeLabel.alpha = 0.0
                self.inputField.alpha = 0.0
                self.actionButton.alpha = 0.0
                self.loadingAnimationView.alpha = 1.0
                self.backButton.alpha = 0.0
                self.forgotPasswordButton.alpha = 0.0
            }) {
                (finished) in
                if finished == false {
                    return
                }
                
                let password = self.inputField.text!
                let request = SignUpRequest(email: self.email, password: password)
                
                Session.send(request) {
                    (result) in
                    switch result {
                    case .success(let session):
                        mainStore.dispatch(AccountAction.signUp(mailAddress: self.email, session: session))
                        self.performSegue(withIdentifier: R.segue.welcomeToCypherpunkViewController.signUp, sender: nil)
                    case .failure:
                        self.state = .getStarted
                        self.startAnimation()
                    }
                }
                
            }

        case .logIn:
            UIView.animate(withDuration: 0.3, animations: {
                self.welcomeLabel.alpha = 0.0
                self.inputField.alpha = 0.0
                self.actionButton.alpha = 0.0
                self.loadingAnimationView.alpha = 1.0
                self.backButton.alpha = 0.0
                self.forgotPasswordButton.alpha = 0.0
                })
            { (finished) in
                if finished {
                    let password = self.inputField.text!
                    let request = LoginRequest(login: self.email, password: password)
                    Session.send(request, callbackQueue: nil, handler: { (result) in
                        switch result {
                        case .success(let response):
                            if response.account.confirmed == false {
                                self.performSegue(withIdentifier: R.segue.welcomeToCypherpunkViewController.signUp, sender: nil)
                                return
                            }
                            
                            let regionRequest = RegionListRequest(session: response.session, accountType: response.account.type)
                            Session.send(regionRequest) { (result) in
                                switch result {
                                case .success(_):
                                    mainStore.dispatch(RegionAction.setup)
                                    mainStore.dispatch(AccountAction.login(response: response))
                                case .failure:
                                    UIView.animate(withDuration: 0.3, animations: {
                                        self.welcomeLabel.alpha = 1.0
                                        self.inputField.alpha = 1.0
                                        self.actionButton.alpha = 1.0
                                        self.loadingAnimationView.alpha = 0.0
                                        self.backButton.alpha = 1.0
                                        self.forgotPasswordButton.alpha = 1.0
                                    })
                                }
                            }
                        case .failure:
                            UIView.animate(withDuration: 0.3, animations: {
                                self.welcomeLabel.alpha = 1.0
                                self.inputField.alpha = 1.0
                                self.actionButton.alpha = 1.0
                                self.loadingAnimationView.alpha = 0.0
                                self.backButton.alpha = 1.0
                                self.forgotPasswordButton.alpha = 1.0
                            })
                            
                            let alertController = UIAlertController(title: "Invalid Password", message: "The password that was entered is incorrect. Please try again.", preferredStyle: .alert)
                            
                            // Create OK button
                            let okAction = UIAlertAction(title: "OK", style: .default)
                            alertController.addAction(okAction)

                            // Present Dialog message
                            self.present(alertController, animated: true, completion:nil)
                        }
                    })
                }
            }
            
        }
    }
    
    @IBAction func backAction(_ sender: AnyObject) {
        switch state {
        case .getStarted:
            break
        case .logIn, .signUp:
            state = .getStarted
            self.inputField.resignFirstResponder()
            startAnimation()
        }
    }
    
    @IBAction func termOfServiceAction(_ sender: Any) {
        let url = URL(string: "https://cypherpunk.com/terms-of-service")
        UIApplication.shared.openURL(url!)
    }
    
    @IBAction func privacyPolicyAction(_ sender: Any) {
        let url = URL(string: "https://cypherpunk.com/privacy-policy")
        UIApplication.shared.openURL(url!)
    }
    func newState(state: AppState)
    {
        if state.accountState.isLoggedIn {
            // TODO: transition to send email screen
            
            let destination = R.storyboard.walkthrough.instantiateInitialViewController()
            self.navigationController?.pushViewController(destination!, animated: true)
        }
    }
    
    private func setPlaceholderText(_ placeholder: String, color: UIColor) {
        let placeholderAttributes = [NSForegroundColorAttributeName: color]
        self.inputField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: placeholderAttributes)
        self.inputField.text = ""
    }
}

extension WelcomeToCypherpunkViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if actionButton.isEnabled {
            startAction()
        }
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var doneButtonIsEnabled = true
        if let newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) {
            switch state {
            case .getStarted:
                if isValidMailAddress(newString) == false {
                    doneButtonIsEnabled = false
                }
            case .logIn, .signUp:
                if newString.characters.count < 6 {
                    doneButtonIsEnabled = false
                }
            }
        } else {
            doneButtonIsEnabled = false
        }
        
        self.actionButton.isEnabled = doneButtonIsEnabled
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.actionButton.isEnabled = false
        return true
    }
}

extension WelcomeToCypherpunkViewController {
    
    func keyboardWillShow(_ sender: Notification) {
        if let userInfo = sender.userInfo {
            
            let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
            let bottomSpace = self.view.frame.height - (actionButton.frame.origin.y + actionButton.frame.height + 20)
            if bottomSpace < keyboardHeight {
                topSpaceConstraint.constant =  -(keyboardHeight - bottomSpace)
            }
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }
    func keyboardWillHide(_ sender: Notification) {
        topSpaceConstraint.constant = 28.0
        UIView.animate(withDuration: 0.25, animations: { () -> Void in self.view.layoutIfNeeded() })
    }
    
    func registerKeyboardNotification() {
        let defaultCenter = NotificationCenter.default
        
        defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)) , name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeKeyboardNotification() {
        let defaultCenter = NotificationCenter.default
        
        defaultCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        defaultCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
}

// Unwind Segue Action
extension WelcomeToCypherpunkViewController {
    @IBAction func returnToWelcomeAction(forSegue segue: UIStoryboardSegue) {
    }
}
