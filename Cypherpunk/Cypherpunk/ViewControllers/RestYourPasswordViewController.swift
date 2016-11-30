//
//  RestYourPasswordViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/10/20.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import APIKit
import SVProgressHUD

class RestYourPasswordViewController: UIViewController {

    var mailAddress: String = ""
    @IBOutlet weak var inputField: ThemedTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        
        inputField.text = mailAddress
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

    @IBAction func submitAction(_ sender: AnyObject) {
        if let email = inputField.text, isValidMailAddress(email) {
            IndicatorView.show()
            let request = RecoverPasswordRequest(email: email)
            Session.send(request) { result in
                switch result {
                case .success:
                    let _ = self.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    SVProgressHUD.showError(withStatus: "\(error)")
                }
                IndicatorView.dismiss()
            }
        }

    }
}
