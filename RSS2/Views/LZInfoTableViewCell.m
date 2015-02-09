//
//  LZInfoTableViewCell.m
//  RSS2
//
//  Created by luzheng1208 on 15/2/9.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import "LZInfoTableViewCell.h"

@implementation LZInfoTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        self.detailTextLabel.numberOfLines = 3;
        
    }
    return self;
    
}



@end
