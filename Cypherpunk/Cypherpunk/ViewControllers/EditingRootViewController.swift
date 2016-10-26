//
//  EditingRootViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/08/18.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class EditingRootViewController: PopoverRootViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(EditingRootViewController.doneAction))
        button.setTitleTextAttributes([
            NSFontAttributeName: R.font.dosisMedium(size: 18.0)!,
            NSForegroundColorAttributeName: UIColor.goldenYellowColor()
            ], for: .normal)

        self.navigationItem.setRightBarButton(button, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func doneAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
