//
//  LZLikeItem.h
//  RSS2
//
//  Created by luzheng1208 on 15/2/7.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "LZItem.h"

@class LZItem;

@interface LZLikeItem : NSManagedObject

@property (nonatomic, retain) NSString * feedtitle;
@property (nonatomic, retain) NSDate * createTime;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) LZItem *item;

+ (void)insertIntoLikeDBWithItem:(LZItem *)item andFeedTitle:(NSString *)feedTitle;
+ (LZLikeItem *)getLikeItemByIdentifier:(NSString *)identifier;
+ (NSMutableArray *)getAllLikeItems;

@end
