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
    [super viewDidAppear:animated];
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


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Show detail
    LZDetailViewController *detail = [[LZDetailViewController alloc]init];
    LZLikeItem *likeItem = [likeItemArray objectAtIndex:indexPath.row];
    detail.feedItem = likeItem.item;
    detail.feedTitle = likeItem.feedtitle;

    [self.navigationController pushViewController:detail animated:YES];
    
    // Deselect
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Respond Methods
- (void)openButtonPressed
{
    [self.sideMenuViewController openMenuAnimated:YES completion:nil];
}

#pragma mark - Notification Responder 
//- (void)modifyDataSource:(NSNotification *)notification {
//    NSLog(@"%@:%@", THIS_FILE, THIS_METHOD);
//    NSMutableArray *identifiers = [[NSMutableArray alloc]init];
//    NSString *identiferToBeDeleted = [notification.userInfo objectForKey:@"identifier"];
//    for (LZLikeItem *likeItem in likeItemArray) {
//        [identifiers addObject:likeItem.item.identifier];
//
//    }
//    if ([identifiers containsObject:identiferToBeDeleted]) {
//        NSLog(@"Delete the likeitem");
//        NSUInteger index = [identifiers indexOfObject:identiferToBeDeleted];
//        NSLog(@"index:%ld",(long)index);
//        [likeItemArray removeObjectAtIndex:index];
//        NSLog(@"LikeItemArray count:%ld", (long)likeItemArray.count);
//    }
//    //NSLog(@"LikeItemArray count:%ld", (long)likeItemArray.count);
//}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
