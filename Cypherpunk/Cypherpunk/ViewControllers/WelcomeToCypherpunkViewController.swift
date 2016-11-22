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

class WelcomeToCypherpunkViewController: UIViewController, StoreSubscriber {
    
    private enum State {
        case getStarted
        case signUp
        case logIn
    }
    
    @IBOutlet weak var topSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var inputField: ThemedTextField!
    @IBOutlet weak var actionButton: TwoColorGradientButton!
    
    @IBOutlet weak var inputContainerView: UIView!
    
    @IBOutlet weak var loadingAnimationView: LoadingAnimationView!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var forgotPasswordButton: UIButton!
    private var email: String = ""
    
    private var state: State = .getStarted
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let attributes: [String: AnyObject] = [
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue as AnyObject,
            NSForegroundColorAttributeName: UIColor.white
        ]
        let forgotPasswordAttributed = NSAttributedString(string: "Forgot Password", attributes: attributes)
        forgotPasswordButton?.setAttributedTitle(forgotPasswordAttributed, for: .normal)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        loadingAnimationView.startAnimation()
        
        self.state = .getStarted
        self.welcomeLabel.text = "Welcome to Cypherpunk"
        self.inputField.placeholder = "Type your email"
        self.inputField.text = self.email
        self.actionButton.setTitle("Get Started", for: .normal)
        self.inputField.isSecureTextEntry = false
        self.inputField.returnKeyType = UIReturnKeyType.next
        self.welcomeLabel.alpha = 1.0
        self.inputContainerView.alpha = 1.0
        self.actionButton.alpha = 1.0
        self.loadingAnimationView.alpha = 0.0

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
            self.inputContainerView.alpha = 0.0
            self.actionButton.alpha = 0.0
            self.loadingAnimationView.alpha = 1.0
            self.backButton.alpha = 0.0
            self.forgotPasswordButton.alpha = 0.0
            
            switch self.state {
            case .getStarted:
                break
            case .logIn:
                self.welcomeLabel.text = "Welcome back!"
                self.inputField.placeholder = "Type your password"
                self.inputField.text = ""
                self.actionButton.setTitle("Log In", for: .normal)
                self.inputField.isSecureTextEntry = true
                self.inputField.returnKeyType = UIReturnKeyType.send
                self.inputField.becomeFirstResponder()
            case .signUp:
                self.welcomeLabel.text = "Hello!\nPlease set your password"
                self.inputField.placeholder = "Type your password"
                self.inputField.text = ""
                self.actionButton.setTitle("Sign Up", for: .normal)
                self.inputField.isSecureTextEntry = true
                self.inputField.returnKeyType = UIReturnKeyType.send
                self.inputField.becomeFirstResponder()
            }

            })
        { (finished) in
            if finished {
                DispatchQueue.main.async {
                    switch self.state {
                    case .getStarted:
                        self.welcomeLabel.text = "Welcome to Cypherpunk"
                        self.inputField.placeholder = "Type your email"
                        self.inputField.text = self.email
                        self.actionButton.setTitle("Get Started", for: .normal)
                        self.inputField.isSecureTextEntry = false
                        self.inputField.returnKeyType = UIReturnKeyType.next
                        
                        UIView.animate(withDuration: 0.3, animations: {
                            self.welcomeLabel.alpha = 1.0
                            self.inputContainerView.alpha = 1.0
                            self.actionButton.alpha = 1.0
                            self.loadingAnimationView.alpha = 0.0
                        })
                    case .logIn:
                        self.welcomeLabel.text = "Welcome back!"
                        self.inputField.placeholder = "Type your password"
                        self.inputField.text = ""
                        self.actionButton.setTitle("Log In", for: .normal)
                        self.inputField.isSecureTextEntry = true
                        self.inputField.returnKeyType = UIReturnKeyType.send
                        self.inputField.becomeFirstResponder()
                        UIView.animate(withDuration: 0.3, animations: {
                            self.welcomeLabel.alpha = 1.0
                            self.inputContainerView.alpha = 1.0
                            self.actionButton.alpha = 1.0
                            self.loadingAnimationView.alpha = 0.0
                            self.backButton.alpha = 1.0
                            self.forgotPasswordButton.alpha = 1.0
                            
                        })
                    case .signUp:
                        self.welcomeLabel.text = "Hello!\nPlease set your password"
                        self.inputField.placeholder = "Type your password"
                        self.inputField.text = ""
                        self.actionButton.setTitle("Sign Up", for: .normal)
                        self.inputField.isSecureTextEntry = true
                        self.inputField.returnKeyType = UIReturnKeyType.send
                        self.inputField.becomeFirstResponder()
                        
                        UIView.animate(withDuration: 0.3, animations: {
                            self.welcomeLabel.alpha = 1.0
                            self.inputContainerView.alpha = 1.0
                            self.actionButton.alpha = 1.0
                            self.loadingAnimationView.alpha = 0.0
                            self.backButton.alpha = 1.0
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
                self.inputContainerView.alpha = 0.0
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
                self.inputContainerView.alpha = 0.0
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
                    case .success:
                        self.performSegue(withIdentifier: R.segue.welcomeToCypherpunkViewController.signUp, sender: nil)
                    case .failure(let error):
                        self.state = .getStarted
                        self.startAnimation()
                    }
                }
                
            }

        case .logIn:
            UIView.animate(withDuration: 0.3, animations: {
                self.welcomeLabel.alpha = 0.0
                self.inputContainerView.alpha = 0.0
                self.actionButton.alpha = 0.0
                self.loadingAnimationView.alpha = 1.0
                self.backButton.alpha = 0.0
                self.forgotPasswordButton.alpha = 0.0
                })
            { (finished) in
                if finished {
                    let password = self.inputField.text!
                    let request = LoginRequest(login: self.email, password: self.inputField.text!)
                    Session.send(request, callbackQueue: nil, handler: { (result) in
                        switch result {
                        case .success(let response):
                            let regionRequest = RegionListRequest(session: response.session)
                            Session.send(regionRequest) { (result) in
                                switch result {
                                case .success(_):
                                    let subscriptionRequest = SubscriptionStatusRequest(session: response.session)
                                    Session.send(subscriptionRequest) {
                                        (result) in
                                        switch result {
                                        case .success(let status):
                                            
                                            mainStore.dispatch(AccountAction.getSubscriptionStatus(status: status))
                                            
                                            let realm = try! Realm()
                                            if let region = realm.objects(Region.self).first {
                                                mainStore.dispatch(RegionAction.changeRegion(regionId: region.id, name: region.regionName, serverIP: region.ipsecDefault, countryCode: region.countryCode, remoteIdentifier: region.ipsecHostname))
                                            }
                                            mainStore.dispatch(AccountAction.login(response: response, password: password))
                                        case .failure(let error):
                                            SVProgressHUD.showError(withStatus: "\((error as NSError).localizedDescription)")
                                        }
                                    }
                                case .failure:
                                    UIView.animate(withDuration: 0.3, animations: {
                                        self.welcomeLabel.alpha = 1.0
                                        self.inputContainerView.alpha = 1.0
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
                                self.inputContainerView.alpha = 1.0
                                self.actionButton.alpha = 1.0
                                self.loadingAnimationView.alpha = 0.0
                                self.backButton.alpha = 1.0
                                self.forgotPasswordButton.alpha = 1.0
                            })
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
            startAnimation()
        }
    }
    
    func newState(state: AppState)
    {
        if state.accountState.isLoggedIn {
            // TODO: transition to send email screen
            
            let destination = R.storyboard.walkthrough.instantiateInitialViewController()
            self.navigationController?.pushViewController(destination!, animated: true)
        }
    }
    
}

extension WelcomeToCypherpunkViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        startAction()
        return false
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
