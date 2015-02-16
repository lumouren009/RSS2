//
//  LZDetailViewController.h
//  RSSReader
//
//  Created by luzheng1208 on 15/2/4.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MWFeedInfo.h"
#import "LZItem.h"

extern int globalFontSize;

@interface LZDetailViewController : UIViewController {
    LZItem *currentFeedItem;
    NSMutableArray *feedItems;
    NSInteger currentItemIndex;
    NSString *itemTitle, *dateString, *summaryString, *contentString, *feedTitle, *identifierString;
}

@property (nonatomic, strong) LZItem *currentFeedItem;
@property (nonatomic, strong) NSMutableArray *feedItems;
@property (nonatomic, assign) NSInteger currentItemIndex;
@property (nonatomic, strong) NSString *itemTitle, *dateString, *summaryString, *contentString, *feedTitle, *identifierString;
@property (nonatomic, strong) MWFeedInfo *feedInfo;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
