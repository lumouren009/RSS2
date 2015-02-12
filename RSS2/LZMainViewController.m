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
#import <MBProgressHUD.h>
#import "UIImage+ProportionalFill.h"


@interface LZMainViewController () <MBProgressHUDDelegate>
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *imageURLStringArray;
@property (nonatomic, strong) NSArray *imageURLStringsToDisplay;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) UIColor *themeColor;
@end


@implementation LZMainViewController

@synthesize itemsToDisplay, appDelegate, managedObjectContext;
@synthesize imageURLStringArray, imageURLStringsToDisplay;
@synthesize hud;
@synthesize themeColor;

-(AppDelegate*)appDelegate
{
    return (AppDelegate*)[[UIApplication sharedApplication]delegate];
}

- (void)viewDidLoad
{
    
    DDLogVerbose(@"%@.%@", THIS_FILE, THIS_METHOD);
    [super viewDidLoad];
    
    // Initialization
    self.appDelegate = [self appDelegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    [self.navigationController.navigationBar setHidden:NO];
    self.refreshControl = [[UIRefreshControl alloc]init];
    self.imageURLStringArray = [[NSMutableArray alloc]init];
    self.imageURLStringsToDisplay = [NSArray array];
    self.itemsToDisplay = [NSArray array];
    self.themeColor = [UIColor whiteColor];
    NSInteger colorTag = [(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:kTextBackgroundColorTag] integerValue];
    [self configureThemeColorWithTag:colorTag];


    
    [self.refreshControl addTarget:self
                            action:@selector(refreshTableView:)
                  forControlEvents:UIControlEventValueChanged];
    
    // Setup environment constants
    self.title = @"Blog titles";
    formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    parsedItems = [[NSMutableArray alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeThemeColor:) name:kChangeThemeColorNotification object:nil];

    
    // BarButtons
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
                                                 target:self action:@selector(openButtonPressed)];
    

    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                 target:self
                                                 action:@selector(refresh)];
   
    self.feedURLString = @"http://blog.devtang.com/atom.xml";
    
    // Hud
    hud = [[MBProgressHUD alloc]initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
   
    hud.delegate = self;
    hud.labelText = NSLocalizedString(@"Loading", nil);
    
    [self parseFeedURL:[NSURL URLWithString:_feedURLString]];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setHidden:NO];
    [self.tableView reloadData];
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
    [imageURLStringArray removeAllObjects];
    [feedParser stopParsing];
    [feedParser parse];
    self.tableView.userInteractionEnabled = NO;

}

- (void)updateTableWithParsedItems {
    DDLogVerbose(@"%@.%@", THIS_FILE, THIS_METHOD);
    self.itemsToDisplay = [parsedItems sortedArrayUsingDescriptors:
                           [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO]]];
    self.imageURLStringsToDisplay = [imageURLStringArray copy];
    self.tableView.userInteractionEnabled = YES;
    self.tableView.alpha = 1;
    [self.tableView reloadData];

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
    [LZManagedObjectManager insertIntoFeedInfoWithMWFeedInfo:info withContext:managedObjectContext];
    
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
        NSLog(@"imageURLStringArray.count:%ld", (long)imageURLStringArray.count);
        if (![str isEqualToString:@""] && ![LZFileTools isFileExistInDocumentDirectory:imageFileName]) {
            [LZFileTools saveImageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:str]] andFileName:imageFileName];
        }

    }
}

- (void)feedParserDidFinish:(MWFeedParser *)parser {
    NSLog(@"Finished Parse");
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
    [self configureCell:cell withIndexPath:indexPath];
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)configureCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath{
    
    MWFeedItem *item = [itemsToDisplay objectAtIndex:indexPath.row];
    if (item) {
        cell.backgroundColor = themeColor;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
        cell.textLabel.textColor = [UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0];
        cell.textLabel.text = item.title ? [item.title stringByConvertingHTMLToPlainText] : @"[No Title]";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@", [formatter stringFromDate:item.date ? item.date : [NSDate date]], item.summary ? [item.summary stringByConvertingHTMLToPlainText] : @"[No Summary]"];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0];
        //cell.backgroundColor = themeColor;
        
        UIImage *cellImage = nil;
        if (![imageURLStringsToDisplay[indexPath.row] isEqualToString:@""]) {
            NSArray *parts = [imageURLStringsToDisplay[indexPath.row] componentsSeparatedByString:@"/"];
            cellImage = [LZFileTools getImageFromFileWithFileName:[parts lastObject]];
            cell.imageView.image = [cellImage imageToFitSize:CGSizeMake(60, 60) method:MGImageResizeCrop];
            
        } else {
            
            cell.imageView.image = [LZImageTools blankImageWithSize:CGSizeMake(60, 60) withColor:cell.backgroundColor];
        }
        cell.imageView.layer.masksToBounds = YES;
        cell.imageView.layer.cornerRadius = 3.0;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

#pragma mark - 
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogVerbose(@"%@.%@", THIS_FILE, THIS_METHOD);
    LZDetailViewController *detail = [[LZDetailViewController alloc]init];
    detail.feedItem = [LZManagedObjectManager convertMWFeedItemIntoItem:(MWFeedItem *)[itemsToDisplay objectAtIndex:indexPath.row] withContext:nil];
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

- (void)configureThemeColorWithTag:(NSInteger) colorTag {
    DDLogVerbose(@"%@.%@", THIS_FILE, THIS_METHOD);
    switch (colorTag) {
        case 0:
            themeColor = [UIColor whiteColor];
            //[toolbar setBarTintColor:[UIColor whiteColor]];
            [UIScreen mainScreen].brightness = 0.8;
            
            break;
        case 1:
            themeColor = [UIColor colorWithRed:1.00 green:0.95 blue:0.80 alpha:1.0];
            //[toolbar setBarTintColor:[UIColor colorWithRed:1.00 green:0.95 blue:0.80 alpha:1.0]];
            [UIScreen mainScreen].brightness = 0.6;
            break;
            
        case 2:
            themeColor = [UIColor colorWithRed:0.26 green:0.26 blue:0.26 alpha:1.0];
            //[toolbar setBarTintColor:[UIColor colorWithRed:0.26 green:0.26 blue:0.26 alpha:1.0]];
            [UIScreen mainScreen].brightness = 0.4;
            break;
            
        case 3:
            themeColor = [UIColor blackColor];
            [UIScreen mainScreen].brightness = 0.2;

            break;
        default:
            break;
    }

}

- (void)changeThemeColor:(NSNotification *)notification {
    NSInteger tag = [[notification.userInfo objectForKey:@"themeColorTag"] integerValue];
    [self configureThemeColorWithTag:tag];
}


@end
