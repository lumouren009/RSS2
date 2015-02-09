//
//  LZItem.m
//  RSS2
//
//  Created by luzheng1208 on 15/2/7.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import "LZItem.h"
#import "AppDelegate.h"


@implementation LZItem

@dynamic author;
@dynamic content;
@dynamic date;
@dynamic identifier;
@dynamic link;
@dynamic summary;
@dynamic title;
@dynamic update;

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

    LZItem *item = [LZItem getItemByIdentifier:feedItem.identifier withContext:managedObjectContext];
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
    
    LZItem *item = [LZItem getItemByIdentifier:feedItem.identifier withContext:managedObjectContext];
    if (item == nil) {
        item = (LZItem *)[NSEntityDescription insertNewObjectForEntityForName:kLZItemEntityString inManagedObjectContext:managedObjectContext];
        item.author = feedItem.author;
        item.content = feedItem.content;
        item.date = feedItem.date;
        item.identifier = feedItem.identifier;
        item.link = feedItem.link;
        item.summary = feedItem.summary;
        item.title = feedItem.title;

    }
    return item;
}

+ (LZItem *)insertIntoItemDBWithItem:(LZItem *)myItem withContext:(NSManagedObjectContext *)managedObjectContext {


    
    LZItem *item = [LZItem getItemByIdentifier:myItem.identifier withContext:managedObjectContext];
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

@end
