//
//  LZFileTools.m
//  RSS2
//
//  Created by luzheng1208 on 15/2/12.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import "LZFileTools.h"

@implementation LZFileTools

+ (BOOL)saveImageWithData:(NSData *)data andFileName:(NSString *)fileName {
    NSLog(@"%@.%@:save file %@", THIS_FILE, THIS_METHOD, fileName);
    if (data == nil) {
        NSLog(@"%@.%@ data is nil", THIS_FILE, THIS_METHOD);
        return NO;
    }
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSLog(@"Saving image");
    NSString *imageFilePath = [docDir stringByAppendingPathComponent:fileName];
    NSData *imageData = [NSData dataWithData:data];
    
    return [imageData writeToFile:imageFilePath atomically:YES];
    
}

+ (UIImage *)getImageFromFileWithFileName:(NSString *)fileName {
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSLog(@"Geting image");
    NSString *imageFilePath = [docDir stringByAppendingPathComponent:fileName];
    
    UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
    return image;
}


+ (void)saveImage:(UIImage *)image withFileName:(NSString *)fileName ofType:(NSString *)extension {
    
    if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"jpeg"]) {
        [self saveImageWithData:UIImageJPEGRepresentation(image, 1.0f) andFileName:fileName];
        
    } else if ([extension isEqualToString:@"png"]) {
        [self saveImageWithData:UIImagePNGRepresentation(image) andFileName:fileName];
        
    } else {
        NSLog(@"Image save failed\n Extention:%@ is not recognized, use(PNG/JPG)", extension);
    }
    
}


+ (BOOL)isFileExistInDocumentDirectory:(NSString *)fileName {
    if (fileName == nil || fileName.length == 0) {
        NSLog(@"%@.%@: File name is nil", THIS_FILE, THIS_METHOD);
        return NO;
    }
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [[NSFileManager defaultManager] fileExistsAtPath:[docDir stringByAppendingPathComponent:fileName]];
}


@end
