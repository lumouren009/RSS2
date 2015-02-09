//
//  LZLikeItem.m
//  RSS2
//
//  Created by luzheng1208 on 15/2/7.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import "LZLikeItem.h"
#import "LZItem.h"
#import "AppDelegate.h"


@implementation LZLikeItem

@dynamic feedtitle;
@dynamic createTime;
@dynamic identifier;
@dynamic item;




+ (void)insertIntoLikeDBWithItem:(LZItem *)item andFeedTitle:(NSString *)feedTitle {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    
    LZLikeItem *likeItem = [LZLikeItem getLikeItemByIdentifier:item.identifier];
    
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


+ (LZLikeItem *)getLikeItemByIdentifier:(NSString *)identifier {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    
    LZLikeItem *likeItem = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LZLikeItem" inManagedObjectContext:managedObjectContext];
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

+ (NSMutableArray *)getAllLikeItems {
    NSLog(@"%@ :%@", THIS_FILE, THIS_METHOD);
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    
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


@end
