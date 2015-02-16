//
//  LZMainViewController.h
//  RSSReader
//
//  Created by luzheng1208 on 15/2/2.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWFeedParser.h"
#import "MWFeedInfo.h"
#import "LZItem.h"



@interface LZMainViewController : UITableViewController <MWFeedParserDelegate> {
    // Parsing
    MWFeedParser *feedParser;
    NSMutableArray *parsedItems;
    
    // Displaying
    NSArray *itemsToDisplay;
    NSDateFormatter *formatter;
}

@property (nonatomic, strong) NSArray *itemsToDisplay;
@property (nonatomic, strong) NSMutableArray *parsedItems;
@property (nonatomic, strong) NSString *feedURLString;
@property (nonatomic, strong) MWFeedInfo *feedInfo;


- (void)parseFeedURL:(NSURL*)feedURL;


@end
