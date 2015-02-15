//
//  LZToolbar.h
//  RSS2
//
//  Created by luzheng1208 on 15/2/15.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LZToolBarDelegate <UIToolbarDelegate>
- (void)backToPreviousPage;
- (void)bookmarkButtonPressed;
- (void)fontButtonPressed;
- (void)shareButtonPressed;

@end

@interface LZToolbar : UIToolbar


@property (nonatomic, strong) UIBarButtonItem *leftBtnItem;
@property (nonatomic, strong) UIBarButtonItem *bookmarkBtn;
@property (nonatomic, strong) UIBarButtonItem *fontBtn;
@property (nonatomic, strong) UIBarButtonItem *shareBtn;
@property (nonatomic, strong) UIBarButtonItem *flexibleSpace;
@property (nonatomic, strong) UIBarButtonItem *fixedSpace;
@property (nonatomic, assign) id <LZToolBarDelegate> delegate;

@end
