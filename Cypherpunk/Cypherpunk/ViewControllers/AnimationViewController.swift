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

    let size = CGSizeMake(15,21)
    
    override func viewDidLoad() {
        super.viewDidLoad()


        let horizontalItemsCount = Int(floor(view.frame.width / size.width))
        let verticalItemsCount = Int(floor(view.frame.height / size.height))
        let font = R.font.dosisRegular(size: 20)

        for x in 0...horizontalItemsCount {
            for y in 0...verticalItemsCount {
                
                let number: Int = random() % 2
                let layoutPoint = CGPoint(x: CGFloat(x) * size.width , y: CGFloat(y) * size.height)
                let frame = CGRect(origin: layoutPoint, size: size)
                
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
                self.view.layer.addSublayer(textLayer)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
