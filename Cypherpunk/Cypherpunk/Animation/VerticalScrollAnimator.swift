//
//  AnimationDelegate.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/08/12.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation
import NetworkExtension

enum AnimationDirection: Int {
    case Down
    case Up
}

class VerticalScrollAnimator: NSObject {
    let itemCount: Int
    let verticalLayer: CALayer
    let direction: AnimationDirection
    let speed: Float
    
    private let animationKeyPath = "position.y"
    private let animationKey = "scrollAnimation"
    private let durationSecPerItem = 21.0 / 2.0
    private let itemSize = CGSizeMake(15,21)
    
    init(itemCount: Int, verticalLayer: CALayer, direction: AnimationDirection, speed: Float = 1.0) {
        self.itemCount = itemCount
        self.verticalLayer = verticalLayer
        self.direction = direction
        self.speed = speed
        super.init()
    }
    
    func animationStart() {
        CATransaction.begin()
        for textLayer in verticalLayer.sublayers! {
            addScrollAnimation(textLayer)
        }
        CATransaction.commit()
    }
    
    func animationStop() {
        for layer in verticalLayer.sublayers! {
            layer.removeAllAnimations()
        }
    }
    
    func animationResume() {
        let pausedTime = verticalLayer.timeOffset
        verticalLayer.speed = 1.0
        verticalLayer.timeOffset = 0.0
        verticalLayer.beginTime = 0.0
        
        let timeSincePause = verticalLayer.convertTime(CACurrentMediaTime(), fromLayer: nil) - pausedTime
        verticalLayer.beginTime = timeSincePause
    }
    
    func animationPause() {
        
        let pausedTime = verticalLayer.convertTime(CACurrentMediaTime(), toLayer: nil)
        verticalLayer.speed = 0.0
        verticalLayer.timeOffset = pausedTime
    }
    
    private func addScrollAnimation(layer: CALayer) {
        let animation = CAKeyframeAnimation(keyPath: animationKeyPath)
        animation.repeatCount = 1.0
        animation.values = valuesForKeyFrame(layer.position.y)
        animation.duration = Double(animation.values!.count) * durationSecPerItem
        animation.speed = speed
        animation.delegate = self
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.removedOnCompletion = false
        layer.addAnimation(animation, forKey: animationKey)
    }
    
    private var count = 0
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if flag == true {

            self.animationPause()
            let itemCount = self.itemCount
            let count = self.count
            let itemSize = self.itemSize
            
            dispatch_async(dispatch_get_main_queue(), {
                let textLayer: CALayer
                
                switch self.direction {
                case .Down:
                    textLayer = self.verticalLayer.sublayers![itemCount - count - 1]
                    textLayer.position = CGPointMake(textLayer.position.x,0)
                case .Up:
                    textLayer = self.verticalLayer.sublayers![count]
                    textLayer.position = CGPointMake(textLayer.position.x, CGFloat(itemCount - 1) * itemSize.height - itemSize.height / 2)
                }
                
                textLayer.removeAnimationForKey(self.animationKey)
                
                self.addScrollAnimation(textLayer)
                self.animationResume()

                self.count = (count + 1) % itemCount
            })
            
        }
    }
    
    func valuesForKeyFrame(startY: CGFloat) -> [CGFloat] {
        let index = Int(startY / itemSize.height)
        var values: [CGFloat] = []
        switch direction {
        case .Down:
            for i in index ..< itemCount  {
                values.append(CGFloat(i - 1) * itemSize.height)
            }
        case .Up:
            for i in 0 ... index + 1 {
                values.append(CGFloat(i - 1) * itemSize.height)
            }
            values = values.reverse()
        }
        return values
    }
    
}