//
//  LZItemFullTableViewCell.m
//  RSS2
//
//  Created by luzheng1208 on 15/2/15.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import "LZItemFullTableViewCell.h"

@implementation LZItemFullTableViewCell

- (void)awakeFromNib {
    // Initialization code

    self.itemTitleLabel.font = [UIFont systemFontOfSize:15.0f];
    self.containerView.layer.cornerRadius = 2.0f;
    self.itemDetailLabel.textColor = [UIColor grayColor];
    self.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    

}

- (void)convertsSimpleFrame {
    self.containerView.frame = CGRectMake(13, 6, 283, 65);
    self.coverImageView.frame = CGRectZero;
    self.coverImageView.image = nil;
    self.itemTitleLabel.frame = CGRectMake(6, 6, 283, 24);
    self.itemDetailLabel.frame = CGRectMake(6, 34, 278, 15);
}

@end
