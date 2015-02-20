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
        return;
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


+(void)insertIntoSubscribeFeedDBWithTitle:(NSString *)title andFeedId:(NSString *)feedId {
    DDLogVerbose(@"%@:%@", THIS_FILE, THIS_METHOD);
    LZSubscribeFeed *feed = [LZManagedObjectManager getSubscribeFeedWithFeedId:feedId withContext:__managedObjectContextOfAppDelegate];
    
    if (feed != nil) {
        return;
    }
    
    if (feed == nil) {
        feed = (LZSubscribeFeed *)[NSEntityDescription insertNewObjectForEntityForName:kLZSubsFeedEntityString inManagedObjectContext:__managedObjectContextOfAppDelegate];
        feed.feedId = feedId;
        feed.feedTitle = title;
    }
}



+ (BOOL)deleteSubscribeFeedWithFeedId:(NSString *)feedId withContext:(NSManagedObjectContext *)context {
    LZSubscribeFeed *feed = [LZManagedObjectManager getSubscribeFeedWithFeedId:feedId withContext:context];
    if (feed) {

        NSString *prefix = [LZStringTools firstMatchInString:feedId withPattern:@"https?://[^/]*/"];
        
        BOOL success = [self deleteAllItemsWithIdentifierPrefix:prefix withContext:context];
        [context deleteObject:feed];
        NSError *error;
        if ([context save:&error]==NO && success) {
            NSLog(@"Delete subscribe feed failed in %@", THIS_METHOD);
        }
        
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

+ (NSArray *)getAllItemsWithIdentifierPrefix:(NSString *)prefix withContext:(NSManagedObjectContext *)context {
    

    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kLZItemEntityString inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier like[c] %@", [prefix stringByAppendingString:@"*"]];
    [fetchRequest setPredicate:predicate];
    
    
    NSError *error;
    NSArray *fetchObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Whoops, couldn't get: %@", [error localizedDescription]);
        
    }
    
    return fetchObjects;
}


+ (LZItem *)insertIntoItemDBWithMWFeedItem:(MWFeedItem *)feedItem coverImageURLString:(NSString *)imageURLString withContext:(NSManagedObjectContext *)managedObjectContext {
    
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
        item.coverImageURLString = imageURLString;
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


+ (BOOL)deleteAllItemsWithIdentifierPrefix:(NSString *)prefix withContext:(NSManagedObjectContext *)context {
    NSArray *deleteObjects = [self getAllItemsWithIdentifierPrefix:prefix
                                                       withContext:context];
    for (LZItem *item in deleteObjects) {
        [context deleteObject:item];
    }
    NSError *error;
    if ([context save:&error]) {
        NSLog(@"Delete items error occurs in %@", THIS_METHOD);
        return NO;
    }
    return YES;
    
}

    

//+ (id)fetchLatestDateofItemByItemIdentifier:(NSString *)identifier withContext:(NSManagedObjectContext *)context {
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:kLZItemEntityString inManagedObjectContext:context];
//    [request setEntity:entity];
//    
//    // Specify that the request should return dictionaries.
//    [request setResultType:NSDictionaryResultType];
//    
//    // Create an expression for the key path.
//    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"date"];
//    
//    // Create an expression to represent the minimum value at the key path 'creationDate'
//    NSExpression *minExpression = [NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:keyPathExpression]];
//    
//    // Create an expression description using the minExpression and returning a date.
//    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
//    
//    // The name is the key that will be used in the dictionary for the return value.
//    [expressionDescription setName:@"maxDate"];
//    [expressionDescription setExpression:minExpression];
//    [expressionDescription setExpressionResultType:NSDateAttributeType];
//    
//    // Set the request's properties to fetch just the property represented by the expressions.
//    [request setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
//    
//    // Execute the fetch.
//    NSError *error = nil;
//    NSArray *objects = [context executeFetchRequest:request error:&error];
//    if (objects == nil) {
//        // Handle the error.
//        NSLog(@"Error occurs in %@", THIS_METHOD);
//    }
//    else {
//        if ([objects count] > 0) {
//            NSLog(@"Maximum date: %@", [[objects objectAtIndex:0] valueForKey:@"maxDate"]);
//        }
//    }
//    return [objects objectAtIndex:0];
//
//}


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
