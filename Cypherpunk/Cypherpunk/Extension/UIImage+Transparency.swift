//
//  UIImage+Transparency.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 6/25/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

// https://stackoverflow.com/a/37955552
extension UIImage {
    func image(alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
