//
//  LZSystemConfig.m
//  RSS2
//
//  Created by luzheng1208 on 15/2/12.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import "LZSystemConfig.h"

@implementation LZSystemConfig


+ (UIColor *)themeColorWithTag:(NSInteger)tag {
    DDLogVerbose(@"%@.%@", THIS_FILE, THIS_METHOD);
    UIColor *themeColor = nil;
    switch (tag) {
        case 0:
            themeColor = [UIColor whiteColor];
            //[toolbar setBarTintColor:[UIColor whiteColor]];
            [UIScreen mainScreen].brightness = 0.8;
            break;
        case 1:
            themeColor = [UIColor colorWithRed:1.00 green:0.95 blue:0.80 alpha:1.0];
            //[toolbar setBarTintColor:[UIColor colorWithRed:1.00 green:0.95 blue:0.80 alpha:1.0]];
            [UIScreen mainScreen].brightness = 0.6;
            break;
        case 2:
            themeColor = [UIColor colorWithRed:0.26 green:0.26 blue:0.26 alpha:1.0];
            //[toolbar setBarTintColor:[UIColor colorWithRed:0.26 green:0.26 blue:0.26 alpha:1.0]];
            [UIScreen mainScreen].brightness = 0.4;
            break;
        case 3:
            themeColor = [UIColor blackColor];
            [UIScreen mainScreen].brightness = 0.2;
            break;
        default:
            break;
    }
    return themeColor;

}

@end
