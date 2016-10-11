//
//  UINavigationController+StatusBar.m
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/06/27.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

#import "UINavigationController+StatusBar.h"


UIStatusBarStyle currentStatusBarStyle = UIStatusBarStyleLightContent;

@implementation UINavigationController (StatusBar)

- (UIStatusBarStyle)preferredStatusBarStyle {
    return currentStatusBarStyle;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskAll;
}

@end

@implementation UIViewController (StatusBar)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (UIStatusBarStyle)preferredStatusBarStyle {
    return currentStatusBarStyle;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskAll;
}
#pragma clang diagnostic pop
@end

@implementation UIApplication (StatusBar)

- (void)changeStatusBarStyleToLightContent
{
    currentStatusBarStyle = UIStatusBarStyleLightContent;
}

- (void)changeStatusBarStyleToDefault
{
    currentStatusBarStyle = UIStatusBarStyleDefault;
}


@end
