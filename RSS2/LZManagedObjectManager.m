//
//  LZManagedObjectManager.m
//  RSS2
//
//  Created by luzheng1208 on 15/2/12.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import "LZManagedObjectManager.h"
#import "AppDelegate.h"

@implementation LZManagedObjectManager



// Manage LZSubscribeFeed entity
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
    LZSubscribeFeed *feed = [LZManagedObjectManager getSubscribeFeedWithFeedId:feedId withContext:context];
    
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
    LZSubscribeFeed *feed = [LZManagedObjectManager getSubscribeFeedWithFeedId:feedId withContext:context];
    if (feed) {
        [context deleteObject:feed];
        return YES;
    } else {
        NSLog(@"Delete subscribe feed failure!!");
        return NO;
    }
}


// Manage LZLikeItem entity
+ (void)insertIntoLikeDBWithItem:(LZItem *)item andFeedTitle:(NSString *)feedTitle withContext:(NSManagedObjectContext *)managedObjectContext {
    
    LZLikeItem *likeItem = [LZManagedObjectManager getLikeItemByIdentifier:item.identifier withContext:managedObjectContext];
    
    if (likeItem != nil) {
        NSLog(@"likeItem is not nil !!!!");
    }
    
    
    if (likeItem == nil) {
        likeItem = (LZLikeItem *)[NSEntityDescription insertNewObjectForEntityForName:@"LZLikeItem" inManagedObjectContext:managedObjectContext];
        likeItem.identifier = item.identifier;
        likeItem.item = item;
        likeItem.createTime = [NSDate date];
        likeItem.feedtitle = feedTitle;
        
        NSError *error;
        if (![managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            
        }
    }
    
}


+ (LZLikeItem *)getLikeItemByIdentifier:(NSString *)identifier withContext:(NSManagedObjectContext *)managedObjectContext {
    
    LZLikeItem *likeItem = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kLZLikeItemEntityString inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    
    NSError *error;
    NSArray *fetchObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Whoops, couldn't get: %@", [error localizedDescription]);
        
    }
    if (fetchObjects && fetchObjects.count >0) {
        likeItem = (LZLikeItem *) [fetchObjects objectAtIndex:0];
    }
    return likeItem;
}

+ (NSMutableArray *)getAllLikeItemsWithContext:(NSManagedObjectContext *)managedObjectContext {
    NSLog(@"%@ :%@", THIS_FILE, THIS_METHOD);
    
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kLZLikeItemEntityString inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Whoops, couldn't get: %@", [error localizedDescription]);
    }
    
    return [fetchedObjects mutableCopy];
}


// Manage LZItem entity

+ (LZItem *)getItemByIdentifier:(NSString *)identifier withContext:(NSManagedObjectContext *)managedObjectContext{
    
    LZItem *item = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kLZItemEntityString inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    
    NSError *error;
    NSArray *fetchObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Whoops, couldn't get: %@", [error localizedDescription]);
        
    }
    if (fetchObjects && fetchObjects.count >0) {
        item = (LZItem *) [fetchObjects objectAtIndex:0];
    }
    return item;
}

+ (LZItem *)insertIntoItemDBWithMWFeedItem:(MWFeedItem *)feedItem withContext:(NSManagedObjectContext *)managedObjectContext {
    
    LZItem *item = [LZManagedObjectManager getItemByIdentifier:feedItem.identifier withContext:managedObjectContext];
    if (item == nil) {
        item = (LZItem *)[NSEntityDescription insertNewObjectForEntityForName:kLZItemEntityString inManagedObjectContext:managedObjectContext];
        item.author = feedItem.author;
        item.content = feedItem.content;
        item.date = feedItem.date;
        item.identifier = feedItem.identifier;
        item.link = feedItem.link;
        item.summary = feedItem.summary;
        item.title = feedItem.summary;
        item.title = feedItem.title;
        //item.updated = feedItem.updated;
        NSError *error;
        if (![managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            
        }
    }
    return item;
}

+ (LZItem *)convertMWFeedItemIntoItem:(MWFeedItem *)feedItem withContext:(NSManagedObjectContext *)managedObjectContext {
    
    //LZItem *item = [LZItem getItemByIdentifier:feedItem.identifier withContext:managedObjectContext];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:kLZItemEntityString inManagedObjectContext:context];
    LZItem *item = (LZItem *)[[NSManagedObject alloc]initWithEntity:entity insertIntoManagedObjectContext:nil];
    
    
    item.author = feedItem.author;
    item.content = feedItem.content;
    item.date = feedItem.date;
    item.identifier = feedItem.identifier;
    item.link = feedItem.link;
    item.summary = feedItem.summary;
    item.title = feedItem.title;
    return item;
}

+ (LZItem *)insertIntoItemDBWithItem:(LZItem *)myItem withContext:(NSManagedObjectContext *)managedObjectContext {
    
    LZItem *item = [LZManagedObjectManager getItemByIdentifier:myItem.identifier withContext:managedObjectContext];
    if (item == nil) {
        item = (LZItem *)[NSEntityDescription insertNewObjectForEntityForName:kLZItemEntityString inManagedObjectContext:managedObjectContext];
        item.author = myItem.author;
        item.content = myItem.content;
        item.date = myItem.date;
        item.identifier = myItem.identifier;
        item.link = myItem.link;
        item.summary = myItem.summary;
        item.title = myItem.title;
        NSError *error;
        if (![managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            
        }
    }
    return item;
}


// Manage LZFeedInfo entity

+ (BOOL)insertIntoFeedInfoWithMWFeedInfo:(MWFeedInfo *)info withContext:(NSManagedObjectContext *)context {
    if (!info) {
        return NO;
    }
    
    LZFeedInfo *infoObject = [self getFeedInfoByURLString:[info.url absoluteString] withContext:context];
    
    if (infoObject == nil) {
        infoObject = (LZFeedInfo *)[NSEntityDescription insertNewObjectForEntityForName:kLZFeedInfoEntityString inManagedObjectContext:context];
        infoObject.url = [info.url absoluteString];
        infoObject.title = info.title;
        infoObject.summary = info.summary;
        infoObject.link = info.link;
        infoObject.createTime = [NSDate date];
        
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
    return YES;
    
}


+ (LZFeedInfo *)getFeedInfoByURLString:(NSString*)URLString withContext:(NSManagedObjectContext *)context {
    LZFeedInfo *info = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LZFeedInfo" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url == %@", URLString];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    
    
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Whoops, couldn't get: %@", [error localizedDescription]);
    }
    if (fetchedObjects && fetchedObjects.count > 0) {
        info = (LZFeedInfo*) [fetchedObjects objectAtIndex:0];
    }
    
    return info;
}

@end