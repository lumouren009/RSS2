//
//  LZFeedInfo.m
//  RSS2
//
//  Created by luzheng1208 on 15/2/7.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import "LZFeedInfo.h"
#import "AppDelegate.h"



@implementation LZFeedInfo

@dynamic createTime;
@dynamic title;
@dynamic url;
@dynamic link;
@dynamic summary;


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
