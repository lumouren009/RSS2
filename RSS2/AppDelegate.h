//
//  AppDelegate.h
//  RSSReader
//
//  Created by luzheng1208 on 15/2/2.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TWTSideMenuViewController.h"
#import <CoreData/CoreData.h>
#import "LZMainViewController.h"
#import "LZMenuViewController.h"
#import "LZLikeMainTableViewController.h"
@class PFObject;
@interface AppDelegate : UIResponder <UIApplicationDelegate, TWTSideMenuViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel * managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) TWTSideMenuViewController *sideMenuViewController;
@property (nonatomic, strong) LZMainViewController *mainViewController;
@property (nonatomic, strong) LZMenuViewController *menuViewController;
@property (nonatomic, strong) LZLikeMainTableViewController *likeMainViewController;

@property (nonatomic, strong) PFObject *subscribeFeeds;
@property (nonatomic, strong) PFObject *favoriteItems;
@property (nonatomic, strong) PFObject *userSettings;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

