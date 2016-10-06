//
//  ContactusViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/08/18.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ContactusViewController: UIViewController {
    
    @IBOutlet weak var textViewContainerView: UIView!
    weak var textView: UITextView!
    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let button = UIBarButtonItem(title: "Submit", style: .done, target: self, action: #selector(ContactusViewController.submitAction))
        self.navigationItem.setRightBarButton(button, animated: false)
        
        registerKeyboardNotification()

        self.automaticallyAdjustsScrollViewInsets = false

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let textView = UITextView(frame: CGRect(x: 3, y: 0, width: self.view.frame.size.width - 3, height: self.textViewContainerView.frame.size.height))
        self.textView = textView
        textView.backgroundColor = UIColor.clear
        textView.font = R.font.dosisMedium(size: 16.0)
        textView.textColor = UIColor.white
        UIView.animate(withDuration: 0.3, animations: {
            textView.delegate = self
            textView.placeholder = "Please describe the issues you are having…"
            self.textViewContainerView.addSubview(textView)
            }, completion: { (finished) in
                if finished {
                }
        }) 

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    deinit{
        removeKeyboardNotification()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func submitAction() {
        _ = self.navigationController?.popViewController(animated: true)
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

extension ContactusViewController: UITextViewDelegate {
    
    func keyboardWillShow(_ sender: Notification) {
        if let userInfo = sender.userInfo {
            if let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect {
                let keyboardHeight = keyboardFrame.size.height
                bottomSpaceConstraint?.constant = keyboardHeight + 44
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    func keyboardWillHide(_ sender: Notification) {
        bottomSpaceConstraint?.constant = 0.0
        UIView.animate(withDuration: 0.25, animations: self.view.layoutIfNeeded)
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
