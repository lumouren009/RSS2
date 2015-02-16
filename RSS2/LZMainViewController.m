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
#import "LZFeedInfo.h"
#import "constants.h"
#import "LZInfoTableViewCell.h"
#import "LZSubscribeFeed.h"
#import "LZImageTools.h"
#import "LZStringTools.h"
#import "LZFileTools.h"
#import <MBProgressHUD.h>
#import "UIImage+ProportionalFill.h"
#import "LZPopTableViewController.h"
#import "LZItemFullTableViewCell.h"


@interface LZMainViewController () <MBProgressHUDDelegate, WYPopoverControllerDelegate>
@property (nonatomic, strong) NSMutableArray *imageURLStringArray;
@property (nonatomic, strong) NSArray *imageURLStringsToDisplay;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) UIColor *themeColor;
@property (nonatomic, strong) WYPopoverController *popoverController;
@property (nonatomic, assign) LZLayoutType currentLayoutType;
@property (nonatomic, assign) BOOL isChangeBlog;
@property (nonatomic, strong) NSString *identifierHostName;
@property (nonatomic, assign) CGRect coverImageViewFrame;

@end


@implementation LZMainViewController
@synthesize itemsToDisplay;
@synthesize imageURLStringArray, imageURLStringsToDisplay;
@synthesize hud;
@synthesize themeColor;
@synthesize popoverController;
@synthesize currentLayoutType;
@synthesize parsedItems;
@synthesize isChangeBlog;
@synthesize identifierHostName;
@synthesize coverImageViewFrame;


- (void)viewDidLoad
{
    
    DDLogVerbose(@"%@.%@", THIS_FILE, THIS_METHOD);
    [super viewDidLoad];
    
    // Initialization
    self.imageURLStringArray = [[NSMutableArray alloc]init];
    self.imageURLStringsToDisplay = [NSArray array];
    self.itemsToDisplay = [NSArray array];
    self.parsedItems = [[NSMutableArray alloc]init];
    self.isChangeBlog = YES;

    

    // Setup environment constants and notification
    self.themeColor = [UIColor whiteColor];
    NSInteger colorTag = [(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:kTextBackgroundColorTag] integerValue];
    self.themeColor = [LZSystemConfig themeColorWithTag:colorTag];
    currentLayoutType = [(NSNumber *) [[NSUserDefaults standardUserDefaults] objectForKey:kMainViewLayout] intValue];
    self.feedURLString = [[NSUserDefaults standardUserDefaults] objectForKey:kLastOpenFeedIdentifier];
    

    self.title = @"Blog titles";
    formatter = [[NSDateFormatter alloc]init];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeThemeColor:) name:kChangeThemeColorNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLayout:) name:kChangeMainViewLayoutNotification object:nil];

    // NavigationItem
    [self.navigationController.navigationBar setHidden:NO];
    FIIcon *leftIcon = [FIEntypoIcon listIcon];
    UIImage *leftImage = [leftIcon imageWithBounds:CGRectMake(0, 0, 20, 20) color:[UIColor grayColor]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:leftImage style:UIBarButtonItemStylePlain target:self action:@selector(openButtonPressed)];

    FIIcon *rightIcon = [FIEntypoIcon cogIcon];
    UIImage *rightImage = [rightIcon imageWithBounds:CGRectMake(0, 0, 20, 20) color:[UIColor grayColor]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:rightImage style:UIBarButtonItemStylePlain target:self action:@selector(configureTableView:)];
    
    // Refresh control
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self
                            action:@selector(refreshTableView:)
                  forControlEvents:UIControlEventValueChanged];

// Hud
//    hud = [[MBProgressHUD alloc]initWithView:self.navigationController.view];
//    [self.navigationController.view addSubview:hud];
//   
//    hud.delegate = self;
//    hud.labelText = NSLocalizedString(@"Loading", nil);
    
    [self parseFeedURL:[NSURL URLWithString:_feedURLString]];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    // NSURL *feedURL = [NSURL URLWithString:@"http://blog.devtang.com/atom.xml"];
    // 阮一峰 http://www.ruanyifeng.com/blog/atom.xml
    [[NSUserDefaults standardUserDefaults] setObject:feedURL.absoluteString forKey:kLastOpenFeedIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    isChangeBlog = YES;
    [parsedItems removeAllObjects];
    [imageURLStringArray removeAllObjects];
    if (feedURL) {
        feedParser = [[MWFeedParser alloc]initWithFeedURL:feedURL];
        feedParser.delegate = self;
        feedParser.feedParseType = ParseTypeFull;
        feedParser.connectionType = ConnectionTypeAsynchronously;
        [feedParser parse];
    } else
    {
        UIAlertView *alterView = [[UIAlertView alloc]initWithTitle:nil message:@"Subscribe on the left menu" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:nil];
        [alterView show];
        
    }
    
}

#pragma mark -
#pragma mark Parsing

// Reset and reparse
- (void)refresh {
    DDLogVerbose(@"%@:%@", THIS_FILE, THIS_METHOD);
    self.title = @"Refreshing";
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
    //isChangeBlog = NO;

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
    [LZManagedObjectManager insertIntoFeedInfoWithMWFeedInfo:info withContext:__managedObjectContextOfAppDelegate];
    
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
    NSLog(@"Parsed Feed Item: “%@”", item.title);
    

    identifierHostName = [LZStringTools firstMatchInString:item.identifier withPattern:@"https?://[^/]*/"];
    NSLog(@"identifierHostName:%@", identifierHostName);
    
    if ([LZManagedObjectManager getItemByIdentifier:item.identifier withContext:__managedObjectContextOfAppDelegate] == nil) {
        [parsedItems addObject:item];
        
        NSString *itemContent = item.content ? item.content:item.summary;
        itemContent = itemContent ? itemContent : @"[No Content]";
        NSString *imageURLTag = [LZStringTools firstMatchInString:itemContent withPattern:@"src=[^>]*(jpg|png)"];
        NSString *str = [imageURLTag isEqualToString:@""] ? @"" : [imageURLTag substringFromIndex:5];
        NSString *imageFileName = [[str componentsSeparatedByString:@"/"] lastObject];
        [imageURLStringArray addObject:str];
        NSLog(@"imageURLStringArray.count:%ld", (long)imageURLStringArray.count);
        if (![str isEqualToString:@""] && ![LZFileTools isFileExistInDocumentDirectory:imageFileName]) {
            [self downloadCoverImageWithURLString:str];
        }
        // Save to LZItem DB
        [LZManagedObjectManager insertIntoItemDBWithMWFeedItem:item coverImageURLString:str withContext:__managedObjectContextOfAppDelegate];
    } else {

        if (isChangeBlog) {
            NSArray *fetchedObjects = [LZManagedObjectManager getAllItemsWithIdentifierPrefix:identifierHostName withContext:__managedObjectContextOfAppDelegate];
            for (LZItem *object in fetchedObjects) {
                [parsedItems addObject:object];
                [imageURLStringArray addObject:object.coverImageURLString];
                
            }
            NSLog(@"imageURLStringArray:%@", imageURLStringArray);
            isChangeBlog = NO;
        }
        [feedParser stopParsing];
        
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
    UITableViewCell *cell;
    NSLog(@"currentLayoutType:%ld", (long)currentLayoutType);
    if (currentLayoutType==LZLayoutList || currentLayoutType==LZLayoutView) {
        cell = (LZInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kTableViewCellIdentifier];
        if (cell==nil) {
            cell = [[LZInfoTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kTableViewCellIdentifier];
        }
        [self configureCell:cell withIndexPath:indexPath];
    }
    
    else if (currentLayoutType == LZLayoutFull) {
        cell = (LZItemFullTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kItemFullTableViewCellIdentifier];
        if (cell==nil) {
            NSArray *cellTeam =
            [[NSBundle mainBundle] loadNibNamed:@"LZItemFullTableViewCell"
                                          owner:self options:nil];
            cell = (LZItemFullTableViewCell *)[cellTeam objectAtIndex:0];
        }
        [self configureFullCell:(LZItemFullTableViewCell *)cell withIndexPath:indexPath];
    }
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (currentLayoutType==LZLayoutList || currentLayoutType==LZLayoutView || [imageURLStringsToDisplay[indexPath.row] isEqualToString:@""])
        return 80;
    else {
        NSArray *parts = [imageURLStringsToDisplay[indexPath.row] componentsSeparatedByString:@"/"];

        if ([LZFileTools isFileExistInDocumentDirectory:[parts lastObject]]) {
            return 230;
        } else {
            return 80;
        }
        

    }

    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogVerbose(@"%@.%@", THIS_FILE, THIS_METHOD);
    LZDetailViewController *detail = [[LZDetailViewController alloc]init];
    detail.currentFeedItem = [LZManagedObjectManager convertMWFeedItemIntoItem:(MWFeedItem *)[itemsToDisplay objectAtIndex:indexPath.row] withContext:nil];
    detail.feedTitle = self.feedInfo.title;
    //detail.feedItems = self.itemsToDisplay;
    detail.feedItems = [[NSMutableArray alloc]init];
    for (NSInteger i=0; i<self.itemsToDisplay.count; i++) {
        LZItem *item = [LZManagedObjectManager convertMWFeedItemIntoItem:self.itemsToDisplay[i] withContext:__managedObjectContextOfAppDelegate];
        [detail.feedItems addObject:item];
    }
    detail.currentItemIndex = indexPath.row;
    [self.navigationController pushViewController:detail animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

}

#pragma mark -  Private methods 
- (void)configureCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    
    MWFeedItem *item = [itemsToDisplay objectAtIndex:indexPath.row];
    if (item) {
        cell.backgroundColor = themeColor;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
        cell.textLabel.textColor = [UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0];
        cell.textLabel.text = item.title ? [item.title stringByConvertingHTMLToPlainText] : @"[No Title]";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@", [formatter stringFromDate:item.date ? item.date : [NSDate date]], item.summary ? [item.summary stringByConvertingHTMLToPlainText] : @"[No Summary]"];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0];
        //cell.backgroundColor = themeColor;
        
        
        if (imageURLStringArray.count > 0 && currentLayoutType == 1) {
            UIImage *cellImage = nil;
            if (![imageURLStringsToDisplay[indexPath.row] isEqualToString:@""]) {
                NSArray *parts = [imageURLStringsToDisplay[indexPath.row] componentsSeparatedByString:@"/"];
                cellImage = [LZFileTools getImageFromFileWithFileName:[parts lastObject]];
                if (cellImage != nil) {
                    cell.imageView.image = [cellImage imageToFitSize:CGSizeMake(60, 60) method:MGImageResizeCrop];
                } else {
                    cell.imageView.image = [LZImageTools blankImageWithSize:CGSizeMake(60, 60) withColor:cell.backgroundColor];
                }
            } else {
                cell.imageView.image = [LZImageTools blankImageWithSize:CGSizeMake(60, 60) withColor:cell.backgroundColor];
            }
            cell.imageView.layer.masksToBounds = YES;
            cell.imageView.layer.cornerRadius = 3.0;
        } else {
            cell.imageView.image = nil;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}
- (void)configureFullCell:(LZItemFullTableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    MWFeedItem *item = [itemsToDisplay objectAtIndex:indexPath.row];
    if (item) {
    
        cell.itemTitleLabel.text = item.title ? [item.title stringByConvertingHTMLToPlainText] : @"[No Title]";
        cell.itemDetailLabel.text = item.summary ? [[item.summary stringByConvertingHTMLToPlainText] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] : @"[No Summary]";
        
        UIImage *cellImage = nil;
        if (![imageURLStringArray[indexPath.row] isEqualToString:@""]) {
            
            if (cell.coverImageView.frame.size.width==0) {
                cell.containerView.frame = CGRectMake(13, 13, 283, 195);
                cell.coverImageView.frame = coverImageViewFrame;
                cell.itemTitleLabel.frame = CGRectMake(6, 136, 283, 24);
                cell.itemDetailLabel.frame = CGRectMake(6, 169, 278, 15);
            }
            
            NSArray *parts = [imageURLStringsToDisplay[indexPath.row] componentsSeparatedByString:@"/"];
            cellImage = [LZFileTools getImageFromFileWithFileName:[parts lastObject]];
            if (cellImage != nil) {
                cell.coverImageView.image = [cellImage imageToFitSize:CGSizeMake(320, 118) method:MGImageResizeCropStart];
            } else {
                if (cell.coverImageView.frame.size.width != 0) {
                    coverImageViewFrame = cell.coverImageView.frame;
                }
                [cell convertsSimpleFrame];
            }
        } else {
            if (cell.coverImageView.frame.size.width != 0) {
                coverImageViewFrame = cell.coverImageView.frame;
            }
            [cell convertsSimpleFrame];
        }
    }
    NSLog(@"current indexpath.row:%ld", (long)indexPath.row);
}


#pragma mark - Notification responds
- (void)changeThemeColor:(NSNotification *)notification {
    NSInteger tag = [[notification.userInfo objectForKey:@"themeColorTag"] integerValue];
    themeColor  = [LZSystemConfig themeColorWithTag:tag];
}

- (void)changeLayout:(NSNotification *)notification {
    LZLayoutType type = [[notification.userInfo objectForKey:@"layout"] intValue];
    NSLog(@"layout:%ld", (long)type);
    currentLayoutType = type;
    [self.tableView reloadData];

    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:type] forKey:kMainViewLayout];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)closePopover:(NSNotification *)notification {
    [popoverController dismissPopoverAnimated:YES completion:^{
        [self popoverControllerDidDismissPopover:popoverController];
    } ];
}


#pragma mark - Outlet action
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

- (void)configureTableView:(UIBarButtonItem *)sender {

    LZPopTableViewController *layoutSelectionTableVC = [[LZPopTableViewController alloc]initWithNibName:nil bundle:nil];
    layoutSelectionTableVC.preferredContentSize = CGSizeMake(160, 90);

    popoverController = [[WYPopoverController alloc]initWithContentViewController:layoutSelectionTableVC];
    popoverController.delegate = self;
    [popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:WYPopoverArrowDirectionDown animated:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(closePopover:) name:kChangeMainViewLayoutNotification object:nil];
}

#pragma mark - Popover Controller delegate
- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    popoverController.delegate = nil;
    popoverController = nil;
}

#pragma mark - Private Methods
- (void)downloadCoverImageWithURLString:(NSString*)str {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:str];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
        
    }];
    [downloadTask resume];
}


@end
