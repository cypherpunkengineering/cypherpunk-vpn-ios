//
//  UIPageControl+Disable.m
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/11/22.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

#import "UIPageControl+Disable.h"

@implementation UIPageControl (Disable)

- (BOOL)isUserInteractionEnabled {
    return NO;
}
@end
