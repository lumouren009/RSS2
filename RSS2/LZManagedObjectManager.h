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
#import "MWFeedItem.h"



@interface LZManagedObjectManager : NSObject

// Manage LZSubscribeFeed entity
+(void)insertIntoSubscribeFeedDBWithTitle:(NSString *)title andFeedId:(NSString *)feedId withContext:(NSManagedObjectContext *)context;
+(void)insertIntoSubscribeFeedDBWithTitle:(NSString *)title andFeedId:(NSString *)feedId;
+ (BOOL)deleteSubscribeFeedWithFeedId:(NSString *)feedId withContext:(NSManagedObjectContext *)context;
+ (BOOL)removeAllSubscribeFeedsInDBwithContext:(NSManagedObjectContext *)context;
+(LZSubscribeFeed *)getSubscribeFeedWithFeedId:(NSString *)feedId withContext:(NSManagedObjectContext *)context;
+(NSArray *)getAllSubscribeFeedsWithContext:(NSManagedObjectContext *)context;  


// Manage LZLikeItem entity
+ (void)insertIntoLikeDBWithItem:(LZItem *)item andFeedTitle:(NSString *)feedTitle withContext:(NSManagedObjectContext *)managedObjectContext;
+ (LZLikeItem *)getLikeItemByIdentifier:(NSString *)identifier withContext:(NSManagedObjectContext*)managedObjectContext;
+ (NSMutableArray *)getAllLikeItemsWithContext:(NSManagedObjectContext *)managedObjectContext;


// Manage LZItem entity
+ (LZItem *)getItemByIdentifier:(NSString *)identifier withContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSArray *)getAllItemsWithIdentifierPrefix:(NSString *)prefix withContext:(NSManagedObjectContext *)context;
+ (LZItem *)insertIntoItemDBWithMWFeedItem:(MWFeedItem *)feedItem coverImageURLString:(NSString*)imageURLString withContext:(NSManagedObjectContext *)managedObjectContext;
+ (LZItem *)insertIntoItemDBWithItem:(LZItem *)item withContext:(NSManagedObjectContext *)managedObjectContext;
+ (LZItem *)convertMWFeedItemIntoItem:(MWFeedItem*)feedItem withContext:(NSManagedObjectContext *)managedObjectContext;
+ (BOOL)deleteAllItemsWithIdentifierPrefix:(NSString *)prefix withContext:(NSManagedObjectContext *)context;

//+ (id)fetchLatestDateofItemByItemIdentifier:(NSString *)identifier withContext:(NSManagedObjectContext *)context;


// Manage LZFeedInfo entity
+ (BOOL)insertIntoFeedInfoWithMWFeedInfo:(MWFeedInfo *)info withContext:(NSManagedObjectContext *)context;
+ (LZFeedInfo *)getFeedInfoByURLString:(NSString*)URLString withContext:(NSManagedObjectContext *)context;


@end
