//
//  LZItem.h
//  RSS2
//
//  Created by luzheng1208 on 15/2/7.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MWFeedItem.h"


@interface LZItem : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * update;


+ (LZItem *)getItemByIdentifier:(NSString *)identifier withContext:(NSManagedObjectContext *)managedObjectContext;
+ (LZItem *)insertIntoItemDBWithMWFeedItem:(MWFeedItem *)feedItem withContext:(NSManagedObjectContext *)managedObjectContext;
+ (LZItem *)insertIntoItemDBWithItem:(LZItem *)item withContext:(NSManagedObjectContext *)managedObjectContext;
+ (LZItem *)convertMWFeedItemIntoItem:(MWFeedItem*)feedItem withContext:(NSManagedObjectContext *)managedObjectContext;

@end
