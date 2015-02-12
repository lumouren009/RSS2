//
//  LZSubscribeFeed.m
//  RSS2
//
//  Created by luzheng1208 on 15/2/9.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import "LZSubscribeFeed.h"


@implementation LZSubscribeFeed

@dynamic feedId;
@dynamic feedTitle;


+(LZSubscribeFeed *)getSubscribeFeedWithFeedId:(NSString *)feedId withContext:(NSManagedObjectContext *)context {
    
    LZSubscribeFeed *feed = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kLZSubsFeedEntityString inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"feedId == %@", feedId];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    
    NSError *error;
    NSArray *fetchObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Whoops, couldn't get: %@", [error localizedDescription]);
    }
    
    if (fetchObjects && fetchObjects.count >0) {
        feed = (LZSubscribeFeed *) [fetchObjects objectAtIndex:0];
    }
    return feed;
    
}


+(NSArray *)getAllSubscribeFeedsWithContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kLZSubsFeedEntityString inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *fetchObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Whoops, couldn't get: %@", [error localizedDescription]);
    }
    return fetchObjects;
    
}


+(void)insertIntoSubscribeFeedDBWithTitle:(NSString *)title andFeedId:(NSString *)feedId withContext:(NSManagedObjectContext *)context {
    DDLogVerbose(@"%@:%@", THIS_FILE, THIS_METHOD);
    LZSubscribeFeed *feed = [LZSubscribeFeed getSubscribeFeedWithFeedId:feedId withContext:context];
    
    if (feed != nil) {
        NSLog(@"subscribeFeed is not nil!!!!");
    }
    
    if (feed == nil) {
        feed = (LZSubscribeFeed *)[NSEntityDescription insertNewObjectForEntityForName:kLZSubsFeedEntityString inManagedObjectContext:context];
        feed.feedId = feedId;
        feed.feedTitle = title;
        
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            
        }
    }
}


+ (BOOL)deleteSubscribeFeedWithFeedId:(NSString *)feedId withContext:(NSManagedObjectContext *)context {
    LZSubscribeFeed *feed = [LZSubscribeFeed getSubscribeFeedWithFeedId:feedId withContext:context];
    if (feed) {
        [context deleteObject:feed];
        return YES;
    } else {
        NSLog(@"Delete subscribe feed failure!!");
        return NO;
    }
}

@end
