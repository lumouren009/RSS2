//
//  LZFeedInfo.h
//  RSS2
//
//  Created by luzheng1208 on 15/2/7.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MWFeedInfo.h"


@interface LZFeedInfo : NSManagedObject

@property (nonatomic, retain) NSDate * createTime;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * summary;


+ (BOOL)insertIntoFeedInfoWithMWFeedInfo:(MWFeedInfo *)info withContext:(NSManagedObjectContext *)context;


+ (LZFeedInfo *)getFeedInfoByURLString:(NSString*)URLString withContext:(NSManagedObjectContext *)context;

@end
