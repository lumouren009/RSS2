//
//  subscribeTextField.m
//  RSSReader
//
//  Created by luzheng1208 on 15/2/7.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import "LZSubscribeTextField.h"

@implementation LZSubscribeTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectOffset(bounds, 5, 0);
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectOffset(bounds, 5, 0);
}

@end
