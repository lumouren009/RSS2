//
//  LZFontConfigPane.h
//  RSS2
//
//  Created by luzheng1208 on 15/2/15.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LZFontConfigPaneDelegate

- (void)reduceFontBtnPressed;
- (void)enlargeFontBtnPressed;
- (void)changeScreenBrightness:(UISlider *)sender;
- (void)setThemeColor:(UIButton *)sender;



@end

@interface LZFontConfigPane : UIView

@property (nonatomic, strong)UIButton *reduceFontBtn;
@property (nonatomic, strong)UIButton *enlargeFontBtn;
@property (nonatomic, strong)UISlider *brightnessSlider;
@property (nonatomic, strong)UIButton *whiteBkgBtn;
@property (nonatomic, strong)UIButton *yellowBkgBtn;
@property (nonatomic, strong)UIButton *grayBkgBtn;
@property (nonatomic, strong)UIButton *blackBkgBtn;

@property (nonatomic, assign) id<LZFontConfigPaneDelegate> delegate;

@end
