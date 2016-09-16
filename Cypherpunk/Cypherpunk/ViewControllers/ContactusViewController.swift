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
        let button = UIBarButtonItem(title: "Submit", style: .Done, target: self, action: #selector(ContactusViewController.submitAction))
        self.navigationItem.setRightBarButtonItem(button, animated: false)
        
        registerKeyboardNotification()

        self.automaticallyAdjustsScrollViewInsets = false

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let textView = UITextView(frame: CGRect(x: 3, y: 0, width: self.view.frame.size.width - 3, height: self.textViewContainerView.frame.size.height))
        self.textView = textView
        textView.backgroundColor = UIColor.clearColor()
        textView.font = R.font.dosisMedium(size: 16.0)
        textView.textColor = UIColor.whiteColor()
        UIView.animateWithDuration(0.3, animations: {
            textView.delegate = self
            textView.placeholder = "Please describe the issues you are having…"
            self.textViewContainerView.addSubview(textView)
            }) { (finished) in
                if finished {
                    textView.becomeFirstResponder()
                }
        }

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    deinit{
        removeKeyboardNotification()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func submitAction() {
        self.navigationController?.popViewControllerAnimated(true)
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
    
    func keyboardWillShow(sender: NSNotification) {
        if let userInfo = sender.userInfo {
            if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size.height {
                bottomSpaceConstraint?.constant = keyboardHeight + 44
                UIView.animateWithDuration(0.25, animations:self.view.layoutIfNeeded)
            }
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        bottomSpaceConstraint?.constant = 0.0
        UIView.animateWithDuration(0.25, animations: self.view.layoutIfNeeded)
    }
    
    func registerKeyboardNotification() {
        let defaultCenter = NSNotificationCenter.defaultCenter()
        
        defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)) , name: UIKeyboardWillShowNotification, object: nil)
        defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotification() {
        let defaultCenter = NSNotificationCenter.defaultCenter()
        
        defaultCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        defaultCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
}
