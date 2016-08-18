//
//  ContactusViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/08/18.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ContactusViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let button = UIBarButtonItem(title: "Submit", style: .Done, target: self, action: #selector(ContactusViewController.submitAction))
        self.navigationItem.setRightBarButtonItem(button, animated: true)
        
        registerKeyboardNotification()
        
        self.automaticallyAdjustsScrollViewInsets = false
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

extension ContactusViewController {
    
    func keyboardWillShow(sender: NSNotification) {
        if let userInfo = sender.userInfo {
            if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size.height {
                bottomSpaceConstraint.constant = keyboardHeight
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        bottomSpaceConstraint.constant = 0.0
        UIView.animateWithDuration(0.25, animations: { () -> Void in self.view.layoutIfNeeded() })
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
