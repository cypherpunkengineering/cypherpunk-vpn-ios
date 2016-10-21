//
//  FormSheetNavigationController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/10/21.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class FormSheetNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func close(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            let location = recognizer.location(in: self.presentingViewController?.view)
            let converted = self.view.convert(location, from: nil)
            if self.view.point(inside: converted, with: nil) == false {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    var tapRecognizer: UITapGestureRecognizer!
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(close(recognizer:)))
            recognizer.numberOfTapsRequired = 1
            recognizer.cancelsTouchesInView = false
            recognizer.delegate = self
            self.view.window?.addGestureRecognizer(recognizer)
            
            tapRecognizer = recognizer
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if tapRecognizer != nil {
            self.view.window?.removeGestureRecognizer(tapRecognizer)
            tapRecognizer = nil
        }
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

}

extension FormSheetNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}
