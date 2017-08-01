//
//  UIColor+CIAdditions.swift
//
//  Generated by Zeplin on 12/21/16.
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved. 
//

import UIKit

extension UIColor {
    /* https://stackoverflow.com/a/33397427 */
	class var goldenYellow: UIColor {
		return UIColor(red: 254.0 / 255.0, green: 207.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
	}
    
    class var seafoamBlue: UIColor {
        return UIColor(red: 95.0 / 255.0, green: 187.0 / 255.0, blue: 196.0 / 255.0, alpha: 1.0)
    }
    
    class var peach: UIColor {
        return UIColor(red: 255.0 / 255.0, green: 177.0 / 255.0, blue: 121.0 / 255.0, alpha: 1.0)
    }
    
    class var darkSlateBlue: UIColor {
        return UIColor(red: 25.0 / 255.0, green: 71.0 / 255.0, blue: 76.0 / 255.0, alpha: 1.0)
    }
    
    class var darkBlueGrey: UIColor {
        return UIColor(red: 22.0 / 255.0, green: 50.0 / 255.0, blue: 56.0 / 255.0, alpha: 1.0)
    }
    
    class var darkNavyBlue: UIColor {
        return UIColor(red: 1.0 / 255.0, green: 0.0, blue: 17.0 / 255.0, alpha: 1.0)
    }
    
    class var robinEggBlue: UIColor {
        return UIColor(red: 141.0 / 255.0, green: 255.0 / 255.0, blue: 252.0 / 255.0, alpha: 1.0)
    }
    
    class var darkCream: UIColor {
        return UIColor(red: 255.0 / 255.0, green: 228.0 / 255.0, blue: 154.0 / 255.0, alpha: 1.0)
    }
    
    class var nastyGreen: UIColor {
        return UIColor(red: 103.0 / 255.0, green: 177.0 / 255.0, blue: 63.0 / 255.0, alpha: 1.0)
    }
    
    class var niceBlue: UIColor {
        return UIColor(red: 25.0 / 255.0, green: 135.0 / 255.0, blue: 189.0 / 255.0, alpha: 1.0)
    }
    
    class var greenyBlue: UIColor {
        return UIColor(red: 80.0 / 255.0, green: 174.0 / 255.0, blue: 183.0 / 255.0, alpha: 1.0)
    }
    
    class var darkBlueGreyTwo: UIColor {
        return UIColor(red: 13.0 / 255.0, green: 30.0 /  255.0, blue: 38.0 / 255.0, alpha: 1.0)
    }
    
    class var burntSienna: UIColor {
        return UIColor(red:0.94, green:0.50, blue:0.38, alpha:1.00)
    }
    
    class var tacao: UIColor {
        return UIColor(red:0.96, green:0.71, blue:0.51, alpha:1.00)
    }
    
    class var configTableBg: UIColor {
        return UIColor(red: 15.0 / 255.0, green: 44.0 /  255.0, blue: 44.0 / 255.0, alpha: 1.0)
    }
    
    class var configTableCellBg: UIColor {
        return UIColor(red: 39.0 / 255.0, green: 97.0 /  255.0, blue: 97.0 / 255.0, alpha: 1.0)
    }

    class var greenVogue: UIColor {
//        26,71,76
        return UIColor(red: 26.0 / 255.0, green: 71.0 / 255.0, blue: 76.0 / 255.0, alpha:1.00)
    }
    
    class var aztec: UIColor {
        // 12 27 30
        return UIColor(red: 12.0 / 255.0, green: 27.0 / 255.0, blue: 30.0 / 255.0, alpha: 1.0)
    }
    
    class var mainScreenBg: UIColor {
        return UIColor(red: 5.0 / 255.0, green: 53.0 / 255.0, blue: 54.0 / 255.0, alpha: 1.0)
    }
    
    class var disconnectedLineColor: UIColor {
        return UIColor(red: 0, green: 112 / 255.0, blue: 112 / 255.0, alpha: 1.0)
    }
    
    class var connectingLineColor: UIColor {
        return UIColor(red: 0, green: 240 / 255.0, blue: 250 / 255.0, alpha: 1.0)
    }
    
    class var connectGlowColor: UIColor {
        return UIColor(red: 196 / 255.0, green: 255 / 255.0, blue: 254 / 255.0, alpha: 1.0)
    }
    
    class var switchThumbBaseColor: UIColor {
        return UIColor(red: 17.0 / 255.0, green: 119.0 / 255.0, blue: 119.0 / 255.0, alpha: 1.0)
    }
    
    class var loginBgColor: UIColor {
        return UIColor(red: 12.0 / 255.0, green: 51.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
    }
    
    /**    https://gist.github.com/mbigatti/c6be210a6bbc0ff25972 */
    /**
     Construct a UIColor using an HTML/CSS RGB formatted value and an alpha value
     
     :param: rgbValue RGB value
     :param: alpha color alpha value
     
     :returns: an UIColor instance that represent the required color
     */
    class func colorWithRGB(rgbValue : UInt, alpha : CGFloat = 1.0) -> UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255
        let green = CGFloat((rgbValue & 0xFF00) >> 8) / 255
        let blue = CGFloat(rgbValue & 0xFF) / 255
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**
     Returns a lighter color by the provided percentage
     
     :param: lighting percent percentage
     :returns: lighter UIColor
     */
    func lighterColor(percent : Double) -> UIColor {
        return colorWithBrightnessFactor(factor: CGFloat(1 + percent));
    }
    
    /**
     Returns a darker color by the provided percentage
     
     :param: darking percent percentage
     :returns: darker UIColor
     */
    func darkerColor(percent : Double) -> UIColor {
        return colorWithBrightnessFactor(factor: CGFloat(1 - percent));
    }
    
    /**
     Return a modified color using the brightness factor provided
     
     :param: factor brightness factor
     :returns: modified color
     */
    func colorWithBrightnessFactor(factor: CGFloat) -> UIColor {
        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0
        
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: hue, saturation: saturation, brightness: brightness * factor, alpha: alpha)
        } else {
            return self;
        }
    }
}
