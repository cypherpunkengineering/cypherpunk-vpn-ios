//
//  SlidingNavigationViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/10/24.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import ECSlidingViewController

class SlidingNavigationViewController: ECSlidingViewController {

    override func awakeFromNib() {
        self.topViewController = R.storyboard.top_iPad.topRootNavigation()
        let right = R.storyboard.top_iPad.slidingContent()
        right?.edgesForExtendedLayout = [UIRectEdge.top , UIRectEdge.bottom, UIRectEdge.right]

        self.underRightViewController = right
        
        self.anchorLeftRevealAmount = 276


    }
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
//
//extension SlidingNavigationViewController: ECSlidingViewControllerLayout, ECSlidingViewControllerDelegate {
// 
//    func slidingViewController(_ slidingViewController: ECSlidingViewController!, frameFor viewController: UIViewController!, topViewPosition: ECSlidingViewControllerTopViewPosition) -> CGRect {
//        return CGRect(x: 0, y: 0, width: 1024, height: self.view.frame.height)
//    }
//
//    func slidingViewController(_ slidingViewController: ECSlidingViewController!, layoutControllerFor topViewPosition: ECSlidingViewControllerTopViewPosition) -> ECSlidingViewControllerLayout! {
//        return self
//    }
//
//}
