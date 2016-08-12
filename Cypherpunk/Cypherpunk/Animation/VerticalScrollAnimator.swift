//
//  AnimationDelegate.swift
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/08/12.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation

enum AnimationDirection: Int {
    case Down
    case Up
}

class VerticalScrollAnimator: NSObject {
    let itemCount: Int
    let verticalLayer: CALayer
    let direction: AnimationDirection
    
    private let itemSize = CGSizeMake(15,21)
    
    init(itemCount: Int, verticalLayer: CALayer, direction: AnimationDirection) {
        self.itemCount = itemCount
        self.verticalLayer = verticalLayer
        self.direction = direction

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
        verticalLayer.removeAllAnimations()
    }
    
    private func addScrollAnimation(layer: CALayer) {
        let animation = CAKeyframeAnimation(keyPath: "position.y")
        animation.repeatCount = 1.0
        animation.values = valuesForKeyFrame(layer.position.y)
        animation.duration = Double(animation.values!.count * 1)
        animation.delegate = self
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        layer.addAnimation(animation, forKey: "scrollAnimation")
    }
    
    private var count = 0
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if flag == true {
            let textLayer: CALayer
            switch direction {
            case .Down:
                textLayer = verticalLayer.sublayers![itemCount - count - 1]
            case .Up:
                textLayer = verticalLayer.sublayers![count]
            }

            switch direction {
            case .Down:
                textLayer.position = CGPointMake(textLayer.position.x,0)
            case .Up:
                textLayer.position = CGPointMake(textLayer.position.x, CGFloat(itemCount - 1) * itemSize.height - itemSize.height / 2)
            }
            
            addScrollAnimation(textLayer)
            
            count = (count + 1) % itemCount
        }
    }
    
    func valuesForKeyFrame(startY: CGFloat) -> [CGFloat] {
        let verticalItemsCount = Int(ceil(verticalLayer.frame.height / itemSize.height))
        let index = Int(startY / itemSize.height)
        var values: [CGFloat] = []
        switch direction {
        case .Down:
            for i in index ... verticalItemsCount {
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