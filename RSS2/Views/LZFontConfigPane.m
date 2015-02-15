//
//  LZFontConfigPane.m
//  RSS2
//
//  Created by luzheng1208 on 15/2/15.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import "LZFontConfigPane.h"

@interface LZFontConfigPane ()


@end

@implementation LZFontConfigPane

@synthesize reduceFontBtn,enlargeFontBtn,brightnessSlider,whiteBkgBtn,yellowBkgBtn,grayBkgBtn,blackBkgBtn;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0]];
        // Reduce font button
        reduceFontBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        reduceFontBtn.frame = CGRectMake(0, 50, kScreenWidth/2, 30);
        [reduceFontBtn setBackgroundColor:[UIColor whiteColor]];
        [reduceFontBtn setTitle:@"-" forState:UIControlStateNormal];
        [reduceFontBtn addTarget:self action:@selector(reduceFontBtnTapped) forControlEvents:UIControlEventTouchUpInside];
        
        // Enlarge font button
        enlargeFontBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        enlargeFontBtn.frame = CGRectMake(kScreenWidth/2+1, 50, kScreenWidth/2, 30);
        [enlargeFontBtn setBackgroundColor:[UIColor whiteColor]];
        [enlargeFontBtn setTitle:@"+" forState:UIControlStateNormal];
        [enlargeFontBtn addTarget:self action:@selector(enlargeFontBtnTapped) forControlEvents:UIControlEventTouchUpInside];

        // Bright slider
        brightnessSlider = [[UISlider alloc]init];
        brightnessSlider.frame = CGRectMake(10, 20, kScreenWidth-20, 2);
        brightnessSlider.value = 0.6;
        brightnessSlider.minimumValue = 0.2;
        brightnessSlider.maximumValue = 1.0;
        [brightnessSlider addTarget:self action:@selector(brightnessSliderDragged:) forControlEvents:UIControlEventValueChanged];
        
        //  Background color button
        whiteBkgBtn = [self buttonWithBackgroundColor:[UIColor whiteColor] andTag:0];
        whiteBkgBtn.frame = CGRectMake(15, 100, kScreenWidth/2, 30);
        [whiteBkgBtn addTarget:self action:@selector(fontColorButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        yellowBkgBtn = [self buttonWithBackgroundColor:[UIColor colorWithRed:1.00 green:0.95 blue:0.80 alpha:1.0] andTag:1];
        yellowBkgBtn.frame = CGRectOffset(whiteBkgBtn.frame, kScreenWidth/5+12, 0);
        [yellowBkgBtn addTarget:self action:@selector(fontColorButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        grayBkgBtn = [self buttonWithBackgroundColor:[UIColor colorWithRed:0.26 green:0.26 blue:0.26 alpha:1.0] andTag:2];
        grayBkgBtn.frame = CGRectOffset(yellowBkgBtn.frame, kScreenWidth/5+12, 0);
        [grayBkgBtn addTarget:self action:@selector(fontColorButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        blackBkgBtn = [self buttonWithBackgroundColor:[UIColor blackColor] andTag:3];
        blackBkgBtn.frame = CGRectOffset(grayBkgBtn.frame, kScreenWidth/5+12 , 0);
        [blackBkgBtn addTarget:self action:@selector(fontColorButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:reduceFontBtn];
        [self addSubview:enlargeFontBtn];
        [self addSubview:brightnessSlider];
        [self addSubview:whiteBkgBtn];
        [self addSubview:yellowBkgBtn];
        [self addSubview:grayBkgBtn];
        [self addSubview:blackBkgBtn];
        
    }
    
    return self;
}

#pragma mark - Private Methods
- (UIButton *)buttonWithBackgroundColor:(UIColor *)color andTag:(NSInteger)tag {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.layer.cornerRadius = 2;
    button.backgroundColor = color;
    button.tag = tag;
    return button;
}

- (void)fontColorButtonTapped:(UIButton *)sender {
    [self.delegate setThemeColor:sender];
}

- (void)reduceFontBtnTapped {
    [self.delegate reduceFontBtnPressed];
}

- (void)enlargeFontBtnTapped {
    [self.delegate enlargeFontBtnPressed];
}

- (void)brightnessSliderDragged:(UISlider *)sender {
    [self.delegate changeScreenBrightness:sender];
}

@end
