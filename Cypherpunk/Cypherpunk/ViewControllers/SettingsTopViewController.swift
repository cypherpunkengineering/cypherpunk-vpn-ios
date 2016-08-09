//
//  SettingsTopViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/05.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class SettingsTopViewController: UIViewController {

    var pageViewController: UIPageViewController!
    var viewControllers: [UIViewController] = []
    
    
    @IBOutlet weak var settingsTriangleLabel: UILabel!
    @IBOutlet weak var statusTriangleLabel: UILabel!
    @IBOutlet weak var displaySettingsButton: UIButton!
    @IBOutlet weak var displayStatusButton: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let settings = storyboard?.instantiateViewController(R.storyboard.settings.settings)!
        let status = storyboard?.instantiateViewController(R.storyboard.settings.status)!
        
        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageViewController.view.frame = containerView.bounds
        
        settings?.view.frame = pageViewController.view.bounds
        status?.view.frame = pageViewController.view.bounds

        viewControllers.append(settings!)
        viewControllers.append(status!)

        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.setViewControllers([viewControllers[0]], direction: .Forward, animated: false, completion: nil)

        self.addChildViewController(pageViewController)
        containerView.addSubview(pageViewController.view)

        displaySettingsAction(displaySettingsButton)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

protocol PageContent {
    var pageIndex: Int { get set }
}

extension SettingsTopViewController: UIPageViewControllerDataSource {
    
    enum Page {
        case Settings
        case Status
        
        static var count: Int { return 2 }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        if let content = viewController as? PageContent {
            let index = content.pageIndex
            
            if index == 0 || index == NSNotFound {
                return nil
            }
        
            return self.viewControllers[index - 1]
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        if let content = viewController as? PageContent {
            let index = content.pageIndex
            
            if index == NSNotFound {
                return nil
            }
            
            if (index + 1) == Page.count {
                return nil
            }
            
            return self.viewControllers[index + 1]
        }
        return nil
    }

    @IBAction func displaySettingsAction(sender: AnyObject) {
        settingsTriangleLabel.hidden = false
        statusTriangleLabel.hidden = true
        
        displayStatusButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
        displaySettingsButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)

        pageViewController.setViewControllers([viewControllers[0]], direction: .Reverse, animated: true, completion: nil)
    }
    @IBAction func displayStatusAction(sender: AnyObject) {
        settingsTriangleLabel.hidden = true
        statusTriangleLabel.hidden = false
        
        displayStatusButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        displaySettingsButton.setTitleColor(UIColor.grayColor(), forState: .Normal)

        pageViewController.setViewControllers([viewControllers[1]], direction: .Forward, animated: true, completion: nil)
    }
}

extension SettingsTopViewController: UIPageViewControllerDelegate {
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished && completed {
            if previousViewControllers.contains(viewControllers[0]) {
                settingsTriangleLabel.hidden = true
                statusTriangleLabel.hidden = false

                displayStatusButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                displaySettingsButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
            } else {
                settingsTriangleLabel.hidden = false
                statusTriangleLabel.hidden = true
                
                displayStatusButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
                displaySettingsButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            }
        }
    }
}