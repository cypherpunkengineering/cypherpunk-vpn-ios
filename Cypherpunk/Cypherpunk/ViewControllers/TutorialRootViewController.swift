//
//  TutorialRootViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/10/20.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

public let ScrollToSecondPage = Notification.Name(rawValue: "ScrollToSecondPage")
public let ScrollToLastPage = Notification.Name(rawValue: "ScrollToLastPage")

class TutorialRootViewController: UIPageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clear
        
        self.setViewControllers([
            R.storyboard.walkthrough.first()!
        ], direction: .forward, animated: true, completion: nil)
        self.dataSource = self
        
        for view in self.view.subviews {
            if let subView = view as? UIScrollView {
                subView.isScrollEnabled = false
            }
        }
        
        NotificationCenter.default.addObserver(forName: ScrollToSecondPage, object: nil, queue: OperationQueue.main) { (notification) in
            self.setViewControllers([
                R.storyboard.walkthrough.second()!
                ], direction: .forward, animated: true, completion: nil)
        }
        NotificationCenter.default.addObserver(forName: ScrollToLastPage, object: nil, queue: OperationQueue.main) { (notification) in
            self.setViewControllers([
                R.storyboard.walkthrough.last()!
                ], direction: .forward, animated: true, completion: nil)
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

extension TutorialRootViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        switch viewController {
        case is CongraturationsViewController:
            return R.storyboard.walkthrough.second()
        case is OneFinalStepViewController:
            return R.storyboard.walkthrough.first()
        default:
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        switch viewController {
        case is SettingUpYourVPNViewController:
            return R.storyboard.walkthrough.second()
        case is OneFinalStepViewController:
            return R.storyboard.walkthrough.last()
        default:
            return nil
        }
    }

}
