//
//  LZManagedObjectManager.h
//  RSS2
//
//  Created by luzheng1208 on 15/2/12.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LZLikeItem.h"
#import "LZItem.h"
#import "LZFeedInfo.h"
#import "LZSubscribeFeed.h"



@interface LZManagedObjectManager : NSObject

// Manage LZSubscribeFeed entity
+(void)insertIntoSubscribeFeedDBWithTitle:(NSString *)title andFeedId:(NSString *)feedId withContext:(NSManagedObjectContext *)context;
+ (BOOL)deleteSubscribeFeedWithFeedId:(NSString *)feedId withContext:(NSManagedObjectContext *)context;
+(LZSubscribeFeed *)getSubscribeFeedWithFeedId:(NSString *)feedId withContext:(NSManagedObjectContext *)context;
+(NSArray *)getAllSubscribeFeedsWithContext:(NSManagedObjectContext *)context;


// Manage LZLikeItem entity
+ (void)insertIntoLikeDBWithItem:(LZItem *)item andFeedTitle:(NSString *)feedTitle withContext:(NSManagedObjectContext *)managedObjectContext;
+ (LZLikeItem *)getLikeItemByIdentifier:(NSString *)identifier withContext:(NSManagedObjectContext*)managedObjectContext;
+ (NSMutableArray *)getAllLikeItemsWithContext:(NSManagedObjectContext *)managedObjectContext;


// Manage LZItem entity
+ (LZItem *)getItemByIdentifier:(NSString *)identifier withContext:(NSManagedObjectContext *)managedObjectContext;
+ (LZItem *)insertIntoItemDBWithMWFeedItem:(MWFeedItem *)feedItem withContext:(NSManagedObjectContext *)managedObjectContext;
+ (LZItem *)insertIntoItemDBWithItem:(LZItem *)item withContext:(NSManagedObjectContext *)managedObjectContext;
+ (LZItem *)convertMWFeedItemIntoItem:(MWFeedItem*)feedItem withContext:(NSManagedObjectContext *)managedObjectContext;


// Manage LZFeedInfo entity
+ (BOOL)insertIntoFeedInfoWithMWFeedInfo:(MWFeedInfo *)info withContext:(NSManagedObjectContext *)context;
+ (LZFeedInfo *)getFeedInfoByURLString:(NSString*)URLString withContext:(NSManagedObjectContext *)context;


@end
