//
//  AnimationViewController.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/08/11.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import CoreGraphics

class AnimationViewController: UIViewController {

    let itemSize = CGSizeMake(15,21)
    var animationLayer: CALayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if animationLayer != nil {
            animationLayer.removeFromSuperlayer()
            animationLayer = instanceAnimationLayer()
            self.view.layer.addSublayer(animationLayer)
            startDisconnectedAnimation()

        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        animationLayer = instanceAnimationLayer()
        self.view.layer.addSublayer(animationLayer)
        startDisconnectedAnimation()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
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
                let number: Int = random() % 2
                let layoutPoint = CGPoint(x: 0 , y: CGFloat(y) * itemSize.height)
                let frame = CGRect(origin: layoutPoint, size: itemSize)
                
                let textLayer = CATextLayer()
                textLayer.string = String(number)
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

    func startDisconnectedAnimation() {
        
        for i in 0 ..< animationLayer.sublayers!.count {
            let verticalLayer = animationLayer.sublayers![i]
            let direction = AnimationDirection(rawValue: i % 2)!
            
            let animator = VerticalScrollAnimator(
                itemCount: verticalLayer.sublayers!.count,
                verticalLayer: verticalLayer,
                direction: direction
            )
            animator.animationStart()
        }
    }
}
