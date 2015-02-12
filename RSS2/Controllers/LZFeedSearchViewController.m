//
//  LZFeedSearchViewController.m
//  RSS2
//
//  Created by luzheng1208 on 15/2/9.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import "LZFeedSearchViewController.h"
#import <AFNetworking.h>
#import <SBJson4.h>
#import "LZSubscribeFeed.h"
#import "AppDelegate.h"


@interface LZFeedSearchViewController () <UISearchBarDelegate>
@property (nonatomic, strong) NSString *queryString;
@property (nonatomic, strong) NSString *requestURLString;
@property (nonatomic, strong) AFHTTPRequestOperationManager *httpManager;
@property (nonatomic, strong) NSMutableArray *feedTitles;
@property (nonatomic, strong) NSMutableArray *feedIds;
@property (nonatomic, strong) UITableView *searchResultsTableView;
@property (nonatomic, strong) UIButton *plusBtn;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, assign) NSUInteger nMarked;
@property (nonatomic, strong) NSMutableArray *subscribeIndexs;

@end

@implementation LZFeedSearchViewController
@synthesize queryString, requestURLString;
@synthesize httpManager;
@synthesize feedTitles;
@synthesize feedIds;
@synthesize searchResultsTableView;
@synthesize plusBtn;
@synthesize appDelegate, context;
@synthesize cancelButton;
@synthesize nMarked;
@synthesize subscribeIndexs;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Initializaiton
    feedTitles = [[NSMutableArray alloc]init];
    feedIds = [[NSMutableArray alloc]init];
    UITableViewController *resultTableVC = (UITableViewController *)self.searchResultsController;
    self.searchResultsTableView = resultTableVC.tableView;
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    context = appDelegate.managedObjectContext;
    self.subscribeIndexs = [[NSMutableArray alloc]init];
    
    
    // Search bar
    self.searchBar.placeholder = NSLocalizedString(@"Search with URL/Key words", nil);
    self.searchBar.delegate = self;
    
    // HTTP request
    
    
}

#pragma mark - UI
- (UIButton *)setupPlusButton {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(0, 0, 10, 10);
    FIIcon *icon = [FIEntypoIcon plusIcon];
    
    FIIconLayer *layer = [FIIconLayer new];
    layer.icon = icon;
    layer.frame = btn.bounds;
    layer.iconColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    [btn.layer addSublayer:layer];
    return btn;
}


#pragma mark - Table View Data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return feedTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCellIdentifier];
    if (OBJ_IS_NIL(cell)) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTableViewCellIdentifier];
        
    }
    cell.textLabel.text = [feedTitles objectAtIndex:indexPath.row];

    if ([self isFeedSubscribedWithFeedId:[feedIds objectAtIndex:indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    } else {
        plusBtn = [self setupPlusButton];
        cell.accessoryView = plusBtn;
    }
    return cell;
}

#pragma mark - Tableview delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@:%@", THIS_FILE, THIS_METHOD);
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        
        // Unsubscribe the feed
        nMarked -= 1;
        cell.accessoryType = UITableViewCellAccessoryNone;
        plusBtn = [self setupPlusButton];
        cell.accessoryView = plusBtn;
        
        if ([self.subscribeIndexs containsObject:[NSNumber numberWithInteger:indexPath.row]]) {
            [self.subscribeIndexs removeObjectIdenticalTo:[NSNumber numberWithInteger:indexPath.row]];
        }
        
        if (nMarked == 0) {
            [self convertButtonTitle:NSLocalizedString(@"Save", nil) toTitle:NSLocalizedString(@"Cancel", nil) inView:self.searchBar];
        }

    } else {
        
        // Subscribe the feed
        nMarked += 1;
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        if ([[cancelButton titleForState:UIControlStateNormal] isEqualToString:NSLocalizedString(@"Save", nil)] == NO) {
            [self convertButtonTitle:NSLocalizedString(@"Cancel", nil) toTitle:NSLocalizedString(@"Save", nil) inView:self.searchBar];
        }
        [self.subscribeIndexs addObject:[NSNumber numberWithInteger:indexPath.row]];
        
    }
    
    NSLog(@"self.subscribeIndexs.count:%ld",(long)self.subscribeIndexs.count);
    

}

- (BOOL)isFeedSubscribedWithFeedId:(NSString *)mfeedId {
    // If the cell's text is not in LZSubscribeFeed
    // Return NO
    if (OBJ_IS_NIL([LZSubscribeFeed getSubscribeFeedWithFeedId:mfeedId withContext:context]))
        return NO;
    else
        return YES;
    
}


- (void)convertButtonTitle:(NSString *)from toTitle:(NSString *)to inView:(UIView *)view
{
    if ([view isKindOfClass:[UIButton class]])
    {
        cancelButton = (UIButton *)view;
        if ([[cancelButton titleForState:UIControlStateNormal] isEqualToString:from])
        {
            [cancelButton setTitle:to forState:UIControlStateNormal];
        }
    }
    
    for (UIView *subview in view.subviews)
    {
        [self convertButtonTitle:from toTitle:to inView:subview];
    }
}





#pragma mark - Search bar delegate


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    nMarked = 0;
    [self convertButtonTitle:NSLocalizedString(@"Save", nil) toTitle:NSLocalizedString(@"Cancel", nil) inView:self.searchBar];
    
    if (searchText.length < 4) {
        [feedTitles removeAllObjects];
        [feedIds removeAllObjects];
        [self.searchResultsTableView reloadData];
    }
    
    
    if (searchText.length >= 4) {
        self.queryString = searchText;
        
        self.requestURLString = [kFeedlySearchAPI stringByAppendingString:queryString];
        requestURLString = [requestURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        httpManager = [AFHTTPRequestOperationManager manager];
        [httpManager GET:requestURLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"JSON: %@", responseObject);
            NSMutableArray *resultsArray = [responseObject objectForKey:@"results"];
            //NSLog(@"resultsArray count:%ld",(long)resultsArray.count);
            [feedTitles removeAllObjects];
            [feedIds removeAllObjects];
            if (resultsArray.count > 0) {
                
                for (NSDictionary *result in resultsArray) {
                    NSString *mFeedId = [[result objectForKey:@"feedId"] substringFromIndex:5];
                    if (OBJ_IS_NIL([LZSubscribeFeed getSubscribeFeedWithFeedId:mFeedId withContext:context])) {
                        
                        [feedTitles addObject:[result objectForKey:@"title"]];
                        [feedIds addObject:mFeedId];
                    }
                    
                }
            }
            [searchResultsTableView reloadData];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];

        
        NSLog(@"queryString:%@",queryString);
    }
    
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    DDLogVerbose(@"%@:%@",THIS_FILE, THIS_METHOD);
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if ([[cancelButton titleForState:UIControlStateNormal] isEqualToString:NSLocalizedString(@"Save", nil)]) {
        for (NSNumber *number in self.subscribeIndexs) {
            [LZSubscribeFeed insertIntoSubscribeFeedDBWithTitle:[self.feedTitles objectAtIndex:number.integerValue] andFeedId:[self.feedIds objectAtIndex:number.integerValue] withContext:context];
        }
    }
    
    [self setActive:NO];
    [[NSNotificationCenter defaultCenter]postNotificationName:kAddFeedNotification object:nil];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
