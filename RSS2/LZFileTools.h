//
//  LZFileTools.h
//  RSS2
//
//  Created by luzheng1208 on 15/2/12.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LZFileTools : NSObject


+ (BOOL) saveImageWithData:(NSData *)imageData andFileName:(NSString *)fileName;

+ (UIImage *)getImageFromFileWithFileName:(NSString *)fileName;

+ (void) saveImage:(UIImage *)image withFileName:(NSString *)fileName ofType:(NSString *)extension;

+ (BOOL) isFileExistInDocumentDirectory:(NSString *)fileName;
@end
