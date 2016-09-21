//
//  LinePathView.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/09/16.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit

class LinePathView: UIView {

    var startPoint: CGPoint?
    var endPoint: CGPoint?
    var controlPoint: CGPoint?
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        if let startPoint = startPoint, let endPoint = endPoint, let controlPoint = controlPoint {
            
            let path = UIBezierPath()
            path.move(to: startPoint)
            path.addLine(to: endPoint)
            UIColor.goldenYellowColor().setStroke()
            path.lineWidth = 2.0
            path.stroke()
        }
    }

}
