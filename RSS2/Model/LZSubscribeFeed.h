//
//  LZSubscribeFeed.h
//  RSS2
//
//  Created by luzheng1208 on 15/2/9.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LZSubscribeFeed : NSManagedObject

@property (nonatomic, retain) NSString * feedId;
@property (nonatomic, retain) NSString * feedTitle;


+(void)insertIntoSubscribeFeedDBWithTitle:(NSString *)title andFeedId:(NSString *)feedId withContext:(NSManagedObjectContext *)context;
+(LZSubscribeFeed *)getSubscribeFeedWithFeedId:(NSString *)feedId withContext:(NSManagedObjectContext *)context;

@end
