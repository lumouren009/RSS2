//
//  LZItemFullTableViewCell.h
//  RSS2
//
//  Created by luzheng1208 on 15/2/15.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LZItemFullTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *coverImageView;
@property (strong, nonatomic) IBOutlet UILabel *itemTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *itemDetailLabel;

@property (strong, nonatomic) IBOutlet UIView *containerView;
- (void)convertsSimpleFrame;
@end
