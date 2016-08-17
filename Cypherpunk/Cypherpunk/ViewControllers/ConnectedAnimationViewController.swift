//
//  ConnectedAnimationViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/12.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class ConnectedAnimationViewController: UIViewController {
    
    let itemSize = CGSizeMake(15,21)
    var animationLayer: CALayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaultCenter = NSNotificationCenter.defaultCenter()
        defaultCenter.addObserver(self, selector: #selector(AnimationViewController.willResignActive), name: UIApplicationWillResignActiveNotification, object: nil)
        defaultCenter.addObserver(self, selector: #selector(AnimationViewController.didBecomeActive), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
    }
    
    func willResignActive() {
        if animationLayer != nil {
            self.animationLayer.removeFromSuperlayer()
            self.animationLayer = self.instanceAnimationLayer()
            self.view.layer.addSublayer(self.animationLayer)
        }
    }
    
    func didBecomeActive() {
        if animationLayer != nil {
            self.startAnimation()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if animationLayer != nil {
            self.startAnimation()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        animationLayer = instanceAnimationLayer()
        self.view.layer.addSublayer(animationLayer)
        startAnimation()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if animationLayer != nil {
            self.animationLayer.removeFromSuperlayer()
            self.animationLayer = self.instanceAnimationLayer()
            self.view.layer.addSublayer(self.animationLayer)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func instanceAnimationLayer() -> CALayer {
        
        let layer = CALayer()
        layer.frame = self.view.frame
        
        let horizontalItemsCount = Int(ceil(view.frame.width / itemSize.width))
        let verticalItemsCount = Int(ceil(view.frame.height / itemSize.height)) + 1
        let font = R.font.dosisRegular(size: 20)
        
        for x in 0...horizontalItemsCount {
            let verticalLayer = CALayer()
            
            let size = CGSize(width: itemSize.width, height: CGFloat(verticalItemsCount) * itemSize.height)
            verticalLayer.frame = CGRect(origin: CGPoint(x: CGFloat(x) * itemSize.width , y: 0), size: size)
            
            for y in 0...verticalItemsCount {
                let character: Character = RandomCharacterGenerator.generate()
                let layoutPoint = CGPoint(x: 0 , y: CGFloat(y) * itemSize.height)
                let frame = CGRect(origin: layoutPoint, size: itemSize)
                
                let textLayer = CATextLayer()
                textLayer.string = String(character)
                textLayer.font = font
                textLayer.fontSize = 20
                let baseColor = UIColor.whiteThemeNavigationColor()
                
                switch mainStore.state.themeState.themeType {
                case .White:
                    textLayer.foregroundColor = baseColor.colorWithAlphaComponent(0.15).CGColor
                case .Black:
                    textLayer.foregroundColor = baseColor.colorWithAlphaComponent(0.5).CGColor
                }
                textLayer.frame = frame
                
                textLayer.alignmentMode = kCAAlignmentCenter
                textLayer.contentsScale = UIScreen.mainScreen().scale
                verticalLayer.addSublayer(textLayer)
            }
            layer.addSublayer(verticalLayer)
        }
        return layer
    }
    
    func animationResume() {
        for animator in animators {
            animator.animationResume()
        }
    }
    
    func animationPause() {
        for animator in animators {
            animator.animationPause()
        }
    }
    
    var animators: [VerticalScrollAnimator] = []
    func startAnimation() {
        animators.removeAll()
        for i in 0 ..< animationLayer.sublayers!.count {
            let verticalLayer = animationLayer.sublayers![i]
            let direction = AnimationDirection(rawValue: i % 2)!
            
            let animator = VerticalScrollAnimator(
                itemCount: verticalLayer.sublayers!.count,
                verticalLayer: verticalLayer,
                direction: direction,
                speed: 3.0
            )
            animator.animationStart()
            animators.append(animator)
        }
    }
    
}
