//
//  AppDelegate.m
//  RSSReader
//
//  Created by luzheng1208 on 15/2/2.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import "AppDelegate.h"
#import "TWTSideMenuViewController.h"
#import "LZMainViewController.h"
#import "LZMenuViewController.h"
#import "constants.h"
#import <DDASLLogger.h>
#import <DDTTYLogger.h>
#import <DDFileLogger.h>
#import <Parse/Parse.h>

@interface AppDelegate ()

@property (nonatomic, strong) NSUserDefaults *userDefaults;
@end

@implementation AppDelegate

@synthesize userDefaults;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Initialize default setting
    [self initDefaultSetting];
    
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    [self setupSideMenuViewController];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // Setup Parse
    [Parse setApplicationId:@"ijE3AzCagK9qTRMgRushxbFtBCB6SSiAIDwp27Gj"
                  clientKey:@"TdRl9lcTWkpPU2jYPDp0ToTn1vBRMygT9SyAruK9"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Parse objects
    self.subscribeFeeds = [PFObject objectWithClassName:@"SubscribeFeeds"];
    self.favoriteItems = [PFObject objectWithClassName:@"FavoriteItems"];
    self.userSettings = [PFObject objectWithClassName:@"UserSettings"];
    

    [PFUser enableAutomaticUser];
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        PFObject *subscribeFeeds = [PFObject objectWithClassName:@"SubscribeFeeds"];
        subscribeFeeds[@"user"] = [PFUser currentUser];
        subscribeFeeds[@"feeds"] = [[NSMutableArray alloc]init];
        [subscribeFeeds save];

    }
    
    //Overide point for customization
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    return YES;
}

- (void)initDefaultSetting {
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithInteger:100] forKey:kGlobalFontSize];
}

- (void)setupSideMenuViewController
{
    self.menuViewController = [[LZMenuViewController alloc] initWithNibName:nil bundle:nil];
    self.mainViewController = [[LZMainViewController alloc] initWithNibName:nil bundle:nil];
    
    self.likeMainViewController = [[LZLikeMainTableViewController alloc]initWithNibName:nil bundle:nil];
    
    
    
    
    self.sideMenuViewController = [[TWTSideMenuViewController alloc]initWithMenuViewController:self.menuViewController mainViewController:[[UINavigationController alloc]initWithRootViewController:self.mainViewController]];
    self.sideMenuViewController.shadowColor = [UIColor blackColor];
    self.sideMenuViewController.edgeOffset = (UIOffset) { .horizontal = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 18.0f : 0.0f };
    self.sideMenuViewController.zoomScale = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 0.5634f : 0.85f;
    
    self.sideMenuViewController.delegate = self;
    self.window.rootViewController = self.sideMenuViewController;

}


#pragma mark - TWTSideMenuViewControllerDelegate

- (UIStatusBarStyle)sideMenuViewController:(TWTSideMenuViewController *)sideMenuViewController statusBarStyleForViewController:(UIViewController *)viewController
{
    if (viewController == self.menuViewController) {
        return UIStatusBarStyleLightContent;
    } else {
        return UIStatusBarStyleDefault;
    }
}

- (void)sideMenuViewControllerWillOpenMenu:(TWTSideMenuViewController *)sender {
    NSLog(@"willOpenMenu");
}

- (void)sideMenuViewControllerDidOpenMenu:(TWTSideMenuViewController *)sender {
    NSLog(@"didOpenMenu");
}

- (void)sideMenuViewControllerWillCloseMenu:(TWTSideMenuViewController *)sender {
    NSLog(@"willCloseMenu");
}

- (void)sideMenuViewControllerDidCloseMenu:(TWTSideMenuViewController *)sender {
    NSLog(@"didCloseMenu");
}

#pragma mark - Core Data stack
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.luzheng.testCoreData" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"LZFeedInfo" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"testCoreData.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}



@end
