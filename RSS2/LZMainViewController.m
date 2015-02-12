//
//  LZMainViewController.m
//  RSSReader
//
//  Created by luzheng1208 on 15/2/2.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import "LZMainViewController.h"
#import "TWTSideMenuViewController.h"
#import "NSString+HTML.h"
#import "LZDetailViewController.h"
#import "DetailTableViewController.h"
#import "AppDelegate.h"
#import "LZFeedInfo.h"
#import "constants.h"
#import "LZInfoTableViewCell.h"
#import "LZSubscribeFeed.h"
#import "LZImageTools.h"
#import "LZStringTools.h"
#import "LZFileTools.h"


@interface LZMainViewController ()
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *imageURLStringArray;
@end


@implementation LZMainViewController

@synthesize itemsToDisplay, appDelegate, managedObjectContext;
@synthesize imageURLStringArray;

-(AppDelegate*)appDelegate
{
    return (AppDelegate*)[[UIApplication sharedApplication]delegate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialization
    self.appDelegate = [self appDelegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    [self.navigationController.navigationBar setHidden:NO];
    self.refreshControl = [[UIRefreshControl alloc]init];
    self.imageURLStringArray = [[NSMutableArray alloc]init];

    
    [self.refreshControl addTarget:self
                            action:@selector(refreshTableView:)
                  forControlEvents:UIControlEventValueChanged];
    
    // Setup
    self.title = @"Blog titles";

    formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    parsedItems = [[NSMutableArray alloc]init];
    self.itemsToDisplay = [NSArray array];
    
    // BarButtons
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
                                                 target:self action:@selector(openButtonPressed)];
    

    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                 target:self
                                                 action:@selector(refresh)];
   
    self.feedURLString = @"http://blog.devtang.com/atom.xml";
    [self parseFeedURL:[NSURL URLWithString:_feedURLString]];
    
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setHidden:NO];
}

#pragma mark - 
#pragma mark Public Methods
- (void)parseFeedURL:(NSURL *)feedURL
{
    
    DDLogVerbose(@"%@.%@", THIS_FILE, THIS_METHOD);
    // Parse
    // NSURL *feedURL = [NSURL URLWithString:@"http://techcrunch.com/feed/"];
    //NSURL *feedURL = [NSURL URLWithString:@"http://blog.devtang.com/atom.xml"];
    //阮一峰 http://www.ruanyifeng.com/blog/atom.xml
    [parsedItems removeAllObjects];
    [imageURLStringArray removeAllObjects];
    feedParser = [[MWFeedParser alloc]initWithFeedURL:feedURL];
    feedParser.delegate = self;
    feedParser.feedParseType = ParseTypeFull;
    feedParser.connectionType = ConnectionTypeAsynchronously;
    [feedParser parse];
}

#pragma mark -
#pragma mark Parsing

// Reset and reparse
- (void)refresh {
    DDLogVerbose(@"%@:%@", THIS_FILE, THIS_METHOD);
    self.title = @"Refreshing";
    [parsedItems removeAllObjects];
    
    [feedParser stopParsing];
    [feedParser parse];
    self.tableView.userInteractionEnabled = NO;

}

- (void)updateTableWithParsedItems {
    DDLogVerbose(@"%@.%@", THIS_FILE, THIS_METHOD);
    self.itemsToDisplay = [parsedItems sortedArrayUsingDescriptors:
                           [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO]]];

    self.tableView.userInteractionEnabled = YES;
    self.tableView.alpha = 1;
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark MWFeedParserDelegate

- (void)feedParserDidStart:(MWFeedParser *)parser {
    NSLog(@"Started Parsing: %@", parser.url);
    [imageURLStringArray removeAllObjects];
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info {
    NSLog(@"Parsed Feed Info: “%@”", info.title);
    self.title = info.title;
    self.feedInfo = info;
    [LZFeedInfo insertIntoFeedInfoWithMWFeedInfo:info withContext:managedObjectContext];
    
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
    NSLog(@"Parsed Feed Item: “%@”", item.title);
    if (item) {
        [parsedItems addObject:item];
        NSString *itemContent = item.content ? item.content:item.summary;
        itemContent = itemContent ? itemContent : @"[No Content]";
        NSString *imageURLTag = [LZStringTools firstMatchInString:itemContent withPattern:@"src=[^>]*(jpg|png)"];
        NSString *str = [imageURLTag isEqualToString:@""] ? @"" : [imageURLTag substringFromIndex:5];
        NSString *imageFileName = [[str componentsSeparatedByString:@"/"] lastObject];
        [imageURLStringArray addObject:str];
        
        if (![str isEqualToString:@""] && ![LZFileTools isFileExistInDocumentDirectory:imageFileName]) {
            [LZFileTools saveImageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:str]] andFileName:imageFileName];
        }

    }
}

- (void)feedParserDidFinish:(MWFeedParser *)parser {
    NSLog(@"Finished Parsing%@", (parser.stopped ? @" (Stopped)" : @""));
    [self updateTableWithParsedItems];
}

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error {
    NSLog(@"Finished Parsing With Error: %@", error);
    if (parsedItems.count == 0) {
        self.title = @"Failed"; // Show failed message in title
    } else {
        // Failed but some items parsed, so show and inform of error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Parsing Incomplete"
                                                        message:@"There was an error during the parsing of this feed. Not all of the feed items could parsed."
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
    }
    [self updateTableWithParsedItems];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return itemsToDisplay.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    LZInfoTableViewCell *cell = (LZInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kTableViewCellIdentifier];
    if (cell==nil) {
        cell = [[LZInfoTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kTableViewCellIdentifier];
    }
    
    MWFeedItem *item = [itemsToDisplay objectAtIndex:indexPath.row];
    if (item) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
        cell.textLabel.text = item.title ? [item.title stringByConvertingHTMLToPlainText] : @"[No Title]";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@", [formatter stringFromDate:item.date ? item.date : [NSDate date]], item.summary ? [item.summary stringByConvertingHTMLToPlainText] : @"[No Summary]"];

        UIImage *cellImage = nil;
        if (![imageURLStringArray[indexPath.row] isEqualToString:@""]) {
            NSArray *parts = [imageURLStringArray[indexPath.row] componentsSeparatedByString:@"/"];
            cellImage = [LZFileTools getImageFromFileWithFileName:[parts lastObject]];
            cell.imageView.image = [LZImageTools imageWithImage:cellImage scaleToSize:CGSizeMake(60, 60)];
        } else {
            cell.imageView.image = [LZImageTools blankImageWithSize:CGSizeMake(60, 60) withColor:[UIColor whiteColor]];
        }
    }
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

#pragma mark - 
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    LZDetailViewController *detail = [[LZDetailViewController alloc]init];
    detail.feedItem = [LZItem convertMWFeedItemIntoItem:(MWFeedItem *)[itemsToDisplay objectAtIndex:indexPath.row] withContext:nil];
    detail.feedTitle = self.feedInfo.title;

    [self.navigationController pushViewController:detail animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


#pragma mark - Refresh control action
- (void)refreshTableView:(UIRefreshControl *)sender {
    DDLogVerbose(@"%@.%@", THIS_FILE, THIS_METHOD);
    [self refresh];
   
    UILabel *titleLabel = [[[[self.refreshControl subviews] firstObject] subviews] lastObject];
    if (titleLabel) {
        titleLabel.numberOfLines = 0;
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        NSString *title = [NSString stringWithFormat:@"Refresh...\nLast update:%@",dateString];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:title];
    }
    [sender endRefreshing];
}


- (void)openButtonPressed
{
    [self.sideMenuViewController openMenuAnimated:YES completion:nil];
}

@end
