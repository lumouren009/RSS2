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
   
   

    
    [self.refreshControl addTarget:self action:@selector(refreshTableView:) forControlEvents:UIControlEventValueChanged];
    

    
    // Setup
    self.title = @"Blog titles";

    formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    parsedItems = [[NSMutableArray alloc]init];
    self.itemsToDisplay = [NSArray array];
    
    // BarButtons
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(openButtonPressed)];
    

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                           target:self
                                                                                           action:@selector(refresh)];
   
    self.feedURLString = @"http://blog.devtang.com/atom.xml";
    [self parseFeedURL:[NSURL URLWithString:_feedURLString]];
    
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kTableViewCellIdentifier];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setHidden:NO];
}

#pragma mark - 
#pragma mark Public Methods
- (void)parseFeedURL:(NSURL *)feedURL
{
    // Parse
    // NSURL *feedURL = [NSURL URLWithString:@"http://techcrunch.com/feed/"];
    //NSURL *feedURL = [NSURL URLWithString:@"http://blog.devtang.com/atom.xml"];
    //阮一峰 http://www.ruanyifeng.com/blog/atom.xml
    [parsedItems removeAllObjects];
    feedParser = [[MWFeedParser alloc]initWithFeedURL:feedURL];
    feedParser.delegate = self;
    feedParser.feedParseType = ParseTypeFull;
    feedParser.connectionType = ConnectionTypeAsynchronously;
    [feedParser parse];
}

#pragma mark - 
#pragma mark Private Methods

- (BOOL)insertIntoFeedInfo:(MWFeedInfo*)info
{
    
    if (!info) {
        return NO;
    }
    
    LZFeedInfo *infoObject = [self getFeedInfoByURLString:[info.url absoluteString]];
    
    if (infoObject == nil) {
        infoObject = (LZFeedInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"LZFeedInfo" inManagedObjectContext:self.managedObjectContext];
        infoObject.url = [info.url absoluteString];
        infoObject.title = info.title;
        infoObject.summary = info.summary;
        infoObject.link = info.link;
        infoObject.createTime = [NSDate date];
        
        NSError *error;
        if (![managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
    return YES;
    
}


- (LZFeedInfo *) getFeedInfoByURLString:(NSString*)URLString
{
    
    LZFeedInfo *info = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LZFeedInfo" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url == %@", URLString];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    
    
    
    NSError *error;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Whoops, couldn't get: %@", [error localizedDescription]);
    }
    if (fetchedObjects && fetchedObjects.count > 0) {
        info = (LZFeedInfo*) [fetchedObjects objectAtIndex:0];
    }
    
    return info;
}


- (void)notifyMenuView:(MWFeedInfo*)info
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddFeedNotification object:self];
}


#pragma mark - 
#pragma mark Parsing

// Reset and reparse
- (void)refresh {
    self.title = @"Refreshing";
    [parsedItems removeAllObjects];
    [feedParser stopParsing];
    [feedParser parse];
    self.tableView.userInteractionEnabled = NO;

}

- (void)updateTableWithParsedItems {
    self.itemsToDisplay = [parsedItems sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO]]];
    [self parseImageURLStringArray];
    self.tableView.userInteractionEnabled = YES;
    self.tableView.alpha = 1;
    [self.tableView reloadData];
}

#pragma mark - Private methods
- (void)parseImageURLStringArray {
    
    
    for (MWFeedItem *item in self.itemsToDisplay) {
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"src=\"[^>]*(jpg|png)\"" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *matchedArray = nil;
       
        NSString *content = item.content ? item.content : item.summary;
        
        matchedArray = [regex matchesInString:content options:0 range:NSMakeRange(0,content.length)];
        
        NSString *str1;
        if (matchedArray.count > 0) {
            NSTextCheckingResult *result1 = matchedArray[0];
        
            if (result1) {
                str1 = [content substringWithRange:result1.range];
                str1 = [str1 substringFromIndex:5];
                str1 = [str1 substringToIndex:str1.length-1];
            } else {
                str1 = @" No match string!";
            }
        } else {
            str1 = @" No match string!!!";
        }
        NSLog(@"str1:%@", str1);
    }
    
   
    
}

#pragma mark -
#pragma mark MWFeedParserDelegate

- (void)feedParserDidStart:(MWFeedParser *)parser {
    NSLog(@"Started Parsing: %@", parser.url);
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info {
    NSLog(@"Parsed Feed Info: “%@”", info.title);
    self.title = info.title;
    self.feedInfo = info;
    [self insertIntoFeedInfo:info];
    [self notifyMenuView:info];
    
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
    NSLog(@"Parsed Feed Item: “%@”", item.title);
    if (item) [parsedItems addObject:item];
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

- (void)openButtonPressed
{
    [self.sideMenuViewController openMenuAnimated:YES completion:nil];
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
        
        cell.imageView.image = [UIImage imageNamed:@"ic_star_w"];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell.
    MWFeedItem *item = [itemsToDisplay objectAtIndex:indexPath.row];
    if (item) {
        
        // Process
        NSString *itemTitle = item.title ? [item.title stringByConvertingHTMLToPlainText] : @"[No Title]";
        NSString *itemSummary = item.summary ? [item.summary stringByConvertingHTMLToPlainText] : @"[No Summary]";
        
        // Set
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
        cell.textLabel.text = itemTitle;
        NSMutableString *subtitle = [NSMutableString string];
        if (item.date) [subtitle appendFormat:@"%@: ", [formatter stringFromDate:item.date]];
        [subtitle appendString:[itemSummary substringToIndex:60]];
        cell.detailTextLabel.text = subtitle;

        
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
    // Show detail
    LZDetailViewController *detail = [[LZDetailViewController alloc]init];
    detail.feedItem = [LZItem convertMWFeedItemIntoItem:(MWFeedItem *)[itemsToDisplay objectAtIndex:indexPath.row]];
    detail.feedTitle = self.feedInfo.title;

    [self.navigationController pushViewController:detail animated:YES];
    
    // Deselect
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


#pragma mark - Refresh control action
- (void)refreshTableView:(UIRefreshControl *)sender {
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

@end
