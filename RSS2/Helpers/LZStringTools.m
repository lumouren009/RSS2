//
//  LZStringTools.m
//  RSS2
//
//  Created by luzheng1208 on 15/2/12.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import "LZStringTools.h"

@implementation LZStringTools

+ (NSString *)firstMatchInString:(NSString *)content withPattern:(NSString *)pattern {
    NSString *firstMatch = @"";
    if (content == nil || content.length == 0) {
        NSLog(@"%@.%@: The content(%@) is nil", THIS_FILE, THIS_METHOD, content);
        return firstMatch;
    }
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matchedArray = [regex matchesInString:content options:0 range:NSMakeRange(0, content.length)];

    if (matchedArray.count > 0) {
        firstMatch = [content substringWithRange:[matchedArray[0] range]];
    } else {
        NSLog(@"%@.%@:No match string of pattern(%@) in content", THIS_FILE, THIS_METHOD, pattern);
    }
    return firstMatch;
}


@end
