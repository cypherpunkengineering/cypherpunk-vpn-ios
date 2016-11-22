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
            self.currentIndex = 1
            self.setViewControllers([
                R.storyboard.walkthrough.second()!
                ], direction: .forward, animated: true, completion: nil)
        }
        NotificationCenter.default.addObserver(forName: ScrollToLastPage, object: nil, queue: OperationQueue.main) { (notification) in
            self.currentIndex = 2
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

    var currentIndex = 0
}

extension TutorialRootViewController: UIPageViewControllerDataSource {
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 2
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentIndex
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        switch viewController {
        case is CongraturationsViewController:
            currentIndex = 1
            return R.storyboard.walkthrough.second()
        case is OneFinalStepViewController:
            currentIndex = 0
            return R.storyboard.walkthrough.first()
        default:
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        switch viewController {
        case is SettingUpYourVPNViewController:
            currentIndex = 1
            return R.storyboard.walkthrough.second()
        case is OneFinalStepViewController:
             currentIndex = 2
            return R.storyboard.walkthrough.last()
        default:
            return nil
        }
    }

}
