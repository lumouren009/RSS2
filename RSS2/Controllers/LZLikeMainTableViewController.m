//
//  LZLikeMainTableViewController.m
//  RSS2
//
//  Created by luzheng1208 on 15/2/7.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import "LZLikeMainTableViewController.h"
#import "AppDelegate.h"
#import "constants.h"
#import "TWTSideMenuViewController.h"
#import "LZLikeItem.h"
#import "NSString+HTML.h"
#import "LZDetailViewController.h"
@interface LZLikeMainTableViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) TWTSideMenuViewController *sideMenuViewController;
@property (nonatomic, strong) NSMutableArray *likeItemArray;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end


@implementation LZLikeMainTableViewController
@synthesize appDelegate;
@synthesize likeItemArray;
@synthesize formatter;
@synthesize managedObjectContext;

- (void)viewDidLoad {
    [super viewDidLoad];
    //Initializaiton
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    self.sideMenuViewController = appDelegate.sideMenuViewController;
    self.likeItemArray = [LZManagedObjectManager getAllLikeItemsWithContext:managedObjectContext];
    self.title = @"Bookmarks";
    
    formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    
    // BarButtons
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(openButtonPressed)];
    
}

-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
    [super viewWillAppear:animated];
    self.likeItemArray = [LZManagedObjectManager getAllLikeItemsWithContext:managedObjectContext];
    [self.tableView reloadData];
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return likeItemArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCellIdentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kTableViewCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell.
    LZLikeItem *likeItem = [likeItemArray objectAtIndex:indexPath.row];
    LZItem *item = likeItem.item;
    if (item) {
        
        // Process
        NSString *itemTitle = item.title ? [item.title stringByConvertingHTMLToPlainText] : @"[No Title]";
        NSString *itemSummary = item.summary ? [item.summary stringByConvertingHTMLToPlainText] : @"[No Summary]";
        
        // Set
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
        cell.textLabel.text = itemTitle;
        NSMutableString *subtitle = [NSMutableString string];
        if (item.date) [subtitle appendFormat:@"%@: ", [formatter stringFromDate:item.date]];
        [subtitle appendString:itemSummary];
        cell.detailTextLabel.text = subtitle;
        
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"likeItem.count%ld", (long)likeItemArray.count);
        LZLikeItem *deleteLikeItem = [likeItemArray objectAtIndex:indexPath.row];
        if (deleteLikeItem) {
            [managedObjectContext deleteObject:deleteLikeItem];
            [managedObjectContext save:nil];
            
        }
        [likeItemArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Show detail
    LZDetailViewController *detail = [[LZDetailViewController alloc]init];
    LZLikeItem *likeItem = [likeItemArray objectAtIndex:indexPath.row];
    detail.currentFeedItem = likeItem.item;
    detail.feedTitle = likeItem.feedtitle;
    detail.feedItems = [[NSMutableArray alloc]init];
    for (NSInteger i=0; i<likeItemArray.count; i++) {
        LZItem *item = [LZManagedObjectManager getItemByIdentifier:[likeItemArray[i] identifier] withContext:managedObjectContext];
        item.isBookmarked = [NSNumber numberWithBool:YES];
        [managedObjectContext save:nil];
        [detail.feedItems addObject:item];
    }
    detail.currentItemIndex = indexPath.row;
    [self.navigationController pushViewController:detail animated:YES];
    
    // Deselect
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Respond Methods
- (void)openButtonPressed
{
    [self.sideMenuViewController openMenuAnimated:YES completion:nil];
}

@end
