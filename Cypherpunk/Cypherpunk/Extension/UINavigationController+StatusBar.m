//
//  UINavigationController+StatusBar.m
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/06/27.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

#import "UINavigationController+StatusBar.h"

@implementation UINavigationController (StatusBar)

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end

@implementation UIViewController (StatusBar)

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
