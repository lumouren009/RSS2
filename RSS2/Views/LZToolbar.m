//
//  LZToolbar.m
//  RSS2
//
//  Created by luzheng1208 on 15/2/15.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import "LZToolbar.h"

@interface LZToolbar ()



@end


@implementation LZToolbar
@synthesize leftBtnItem, bookmarkBtn, fontBtn, shareBtn, flexibleSpace,fixedSpace;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSMutableArray *items = [[NSMutableArray alloc]init];
        
        // Left Arrow
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        leftButton.frame = CGRectMake(0, 0, 23, 23);
        FIIcon *icon = [FIEntypoIcon chevronThinLeftIcon];
        
        FIIconLayer *layer = [FIIconLayer new];
        layer.icon = icon;
        layer.frame = leftButton.bounds;
        layer.iconColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
        [leftButton.layer addSublayer:layer];
        [leftButton addTarget:self action:@selector(leftButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
        leftBtnItem.enabled = NO;
        
        // Bookmark Button
        UIImage *starImage = [UIImage imageNamed:@"ic_star_w"];
        bookmarkBtn = [[UIBarButtonItem alloc]initWithImage:starImage style:UIBarButtonItemStylePlain target:self action:@selector(bookmarkBtnTapped:)];
        bookmarkBtn.tintColor = [UIColor blackColor];
        
        // Font Button
        fontBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"ic_font"] style:UIBarButtonItemStylePlain target:self action:@selector(fontBtnTapped:)];
        fontBtn.tintColor = [UIColor blackColor];
        
        // Share Button
        shareBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareBtnTapped:)];
        shareBtn.tintColor = [UIColor blackColor];
        
        flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        fixedSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        
        [items addObjectsFromArray:@[fixedSpace, leftBtnItem, flexibleSpace, bookmarkBtn, flexibleSpace, fontBtn, flexibleSpace, shareBtn, fixedSpace]];
        
        
        [self setItems:items];
        
    }
    
    return self;
}


#pragma mark - Private Methods
- (void)leftButtonTapped:(UIBarButtonItem *)sender {
    [self.delegate backToPreviousPage];
}

- (void)bookmarkBtnTapped:(UIBarButtonItem *)sender {
    [self.delegate bookmarkButtonPressed];
}

- (void)fontBtnTapped:(UIBarButtonItem *)sender {
    [self.delegate fontButtonPressed];
}

- (void)shareBtnTapped:(UIBarButtonItem *)sender {
    [self.delegate shareButtonPressed];
}

@end
