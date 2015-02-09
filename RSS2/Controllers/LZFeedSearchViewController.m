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


@interface LZFeedSearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (nonatomic, strong) NSString *queryString;
@property (nonatomic, strong) NSString *requestURLString;
@property (nonatomic, strong) AFHTTPRequestOperationManager *httpManager;
@property (nonatomic, strong) NSMutableArray *feedTitles;
@property (nonatomic, strong) NSMutableArray *feedIds;
@property (nonatomic, strong) UITableView *searchResultsTableView;

@end

@implementation LZFeedSearchViewController
@synthesize queryString, requestURLString;
@synthesize httpManager;
@synthesize feedTitles;
@synthesize feedIds;
@synthesize searchResultsTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Initializaiton
    feedTitles = [[NSMutableArray alloc]init];
    feedIds = [[NSMutableArray alloc]init];
    UITableViewController *resultTableVC = (UITableViewController *)self.searchResultsController;
    self.searchResultsTableView = resultTableVC.tableView;

    
    
    
    // Search bar
    self.searchBar.placeholder = @"输入URL/关键字";
    self.searchBar.delegate = self;
    
    // HTTP request
    

    
    
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
        UIButton *plusBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        plusBtn.frame = CGRectMake(0, 0, 10, 10);
        FIIcon *icon = [FIEntypoIcon plusIcon];
        
        FIIconLayer *layer = [FIIconLayer new];
        layer.icon = icon;
        layer.frame = plusBtn.bounds;
        layer.iconColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
        [plusBtn.layer addSublayer:layer];
        cell.accessoryView = plusBtn;
    }
    cell.textLabel.text = [feedTitles objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - Search bar delegate


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

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
            NSLog(@"JSON: %@", responseObject);
            NSMutableArray *resultsArray = [responseObject objectForKey:@"results"];
            NSLog(@"resultsArray count:%ld",(long)resultsArray.count);
            [feedTitles removeAllObjects];
            [feedIds removeAllObjects];
            if (resultsArray.count > 0) {
                
                for (NSDictionary *result in resultsArray) {
                    [feedTitles addObject:[result objectForKey:@"title"]];
                    [feedIds addObject:[[result objectForKey:@"feedId"] substringFromIndex:5]];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
