//
//  ImageTools.h
//  RSS2
//
//  Created by luzheng1208 on 15/2/12.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LZImageTools : NSObject


+ (UIImage *)imageWithImage:(UIImage *)image scaleToSize:(CGSize)newSize;


+ (UIImage *)blankImageWithSize:(CGSize)size withColor:(UIColor *)color;


@end
