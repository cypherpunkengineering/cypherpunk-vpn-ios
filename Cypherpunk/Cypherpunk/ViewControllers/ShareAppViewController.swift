//
//  ShareAppViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/11/07.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import FontAwesome_swift
import Social
import MessageUI

class ShareAppViewController: UIViewController {

    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let iconSize = CGSize(width: 22, height: 22)
        facebookButton.setImage(UIImage.fontAwesomeIcon(name: .facebookOfficial, textColor: UIColor.white, size: iconSize).withRenderingMode(.alwaysOriginal), for: .normal)
        twitterButton.setImage(UIImage.fontAwesomeIcon(name: .twitter, textColor: UIColor.white, size: iconSize).withRenderingMode(.alwaysOriginal), for: .normal)
        emailButton.setImage(UIImage.fontAwesomeIcon(name: .envelopeO, textColor: UIColor.white, size: iconSize).withRenderingMode(.alwaysOriginal), for: .normal)

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

    @IBAction func facebookShareAction(_ sender: Any) {
        guard let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook) else { return }
        vc.add(URL(string: "https://cypherpunk.com/"))
        vc.completionHandler = { result in
            switch result {
            case .done:
                // get 30 days?
                break
            case .cancelled:
                break
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func twitterShareAction(_ sender: Any) {
        guard let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter) else { return }
        vc.setInitialText("Protect yourself with Cypherpunk Privacy")
        vc.add(URL(string: "https://cypherpunk.com/"))
        vc.completionHandler = { result in
            switch result {
            case .done:
                // get 30 days?
                break
            case .cancelled:
                break
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func emailShareAction(_ sender: Any) {
        let vc = MFMailComposeViewController()
        vc.setSubject("Cypherpunk Privacy App Invitation")
        vc.setMessageBody("Protect yourself with Cypherpunk Privacy\nhttps://cypherpunk.com/", isHTML: false)
        vc.mailComposeDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
}

extension ShareAppViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .sent:
            // get 30 days?
            break
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
        
    }
}
