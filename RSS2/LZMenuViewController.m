//
//  LZMenuViewController.m
//  RSSReader
//
//  Created by luzheng1208 on 15/2/2.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import "LZMenuViewController.h"
#import "TWTSideMenuViewController.h"
#import "LZMainViewController.h"
#import "LZFeedInfo.h"
#import "constants.h"
#import "LZSubscribeTextField.h"
#import "LZLikeMainTableViewController.h"
#import "LZFeedSearchViewController.h"
#import "LZSubscribeFeed.h"
#import "LZSettingTableViewController.h"


static NSString * const kTableViewCellIndentifier = @"com.luzheng.LZMenuViewController.sampleCell";

@interface LZMenuViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) NSString *rssURL;

@property (nonatomic, strong) LZSubscribeTextField *subscribeURLTextField;

@property (nonatomic, strong) UIButton *addWebsiteBtn, *subscribeBtn;

@property (nonatomic, strong) UITableView *feedsTitleTableView;

@property (nonatomic, strong) NSMutableArray *feedURLArray;

@property (nonatomic, strong) NSMutableArray *subscribeFeeds;




@end

@implementation LZMenuViewController

@synthesize  subscribeURLTextField, addWebsiteBtn, subscribeBtn, feedsTitleTableView;
@synthesize subscribeFeeds;



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Fetch blog titles
    self.subscribeFeeds = [[LZManagedObjectManager getAllSubscribeFeedsWithContext:__managedObjectContextOfAppDelegate] mutableCopy];
    
    // Setup UI
    [self setupUI];
    
    // Setup observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFeedsTitleSection:) name:kUpdateSubscribeFeedListNotification object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark -
#pragma mark Private Methods

- (void)setupUI
{
    self.view.backgroundColor = [UIColor grayColor];
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGRect imageViewRect = [[UIScreen mainScreen] bounds];
    imageViewRect.size.width += 589;
    self.backgroundImageView.frame = imageViewRect;
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.backgroundImageView];
    
    NSDictionary *viewDict = @{ @"imageView" : self.backgroundImageView };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView]" options:0 metrics:nil views:viewDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[imageView]" options:0 metrics:nil views:viewDict]];
    
    
    
    // Add Website Button
    addWebsiteBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    addWebsiteBtn.frame = CGRectMake(10.0f, 124.0f, 228.0f, 30.0f);
    [addWebsiteBtn setBackgroundColor:[UIColor whiteColor]];
    [addWebsiteBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [addWebsiteBtn setTitle:@"Add Website" forState:UIControlStateNormal];
    addWebsiteBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    [addWebsiteBtn addTarget:self action:@selector(addWebsiteBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    addWebsiteBtn.layer.cornerRadius = 2;
    [self.view addSubview:addWebsiteBtn];
    
    // Add Subscribe Button
    NSData *archievedData =  [NSKeyedArchiver archivedDataWithRootObject:addWebsiteBtn];
    subscribeBtn = [NSKeyedUnarchiver unarchiveObjectWithData:archievedData];
    [subscribeBtn setTitle:@"Subscribe" forState:UIControlStateNormal];
    subscribeBtn.alpha = 0.0;
    subscribeBtn.layer.cornerRadius = 2.0;
    [subscribeBtn addTarget:self action:@selector(subscribeBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:subscribeBtn];
    
    
    // Subscribe Text Field
    subscribeURLTextField = [[LZSubscribeTextField alloc]init];
    subscribeURLTextField.frame = CGRectMake(10.0f, 124.0f, 165.0f, 30.0f);
    [subscribeURLTextField setPlaceholder:@"RSS地址"];
    subscribeURLTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [subscribeURLTextField setBackgroundColor:[UIColor whiteColor]];
    subscribeURLTextField.layer.cornerRadius = 2;
    [subscribeURLTextField setDelegate:self];

    [self.view addSubview:subscribeURLTextField];
    subscribeURLTextField.alpha = 0.0;
    
    // Feeds Title Table View
    feedsTitleTableView = [[UITableView alloc]initWithFrame:CGRectMake(10.0f, 160.0f, 228.0f, 280.0f) style:UITableViewStyleGrouped];
    //feedsTitleTableView.scrollEnabled = NO;

    feedsTitleTableView.dataSource = self;
    feedsTitleTableView.delegate = self;
    [self.view addSubview:feedsTitleTableView];
    
}

- (void)updateFeedsTitleSection:(NSNotification*)notification{
    self.subscribeFeeds = [[LZManagedObjectManager getAllSubscribeFeedsWithContext:__managedObjectContextOfAppDelegate] mutableCopy];
    NSLog(@"Observe the notification");
    [self.feedsTitleTableView reloadData];
}

#pragma mark - Table view data source
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    switch (indexPath.section) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"readItLaterCellIdentifier"];
            if (cell==nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"readItLaterCellIdentifier"];
            }
            break;
        case 1: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"feedTitleCellIdentifier"];
            if (cell==nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"feedTitleCellIdentifier"];
            }
            break;
        }
        case 2:{
            cell = [tableView dequeueReusableCellWithIdentifier:@"settingCellIdentifier"];
            if (cell==nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"settingCellIdentifier"];
            }
            
            break;
        }
        default:
            break;
    }
    
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    LZSubscribeFeed *feed;
    switch (indexPath.section) {
        case 0: {
            cell.textLabel.text = @"Read it Later";
            FIIcon *icon = [FIEntypoIcon bookmarkIcon];
            UIImage *image = [icon imageWithBounds:CGRectMake(0, 0, 20, 20) color:[UIColor grayColor]];
            cell.imageView.image = image;
            break;
        }
        case 1: {
            feed = (LZSubscribeFeed*)[subscribeFeeds objectAtIndex:indexPath.row];
            cell.textLabel.text = feed.feedTitle;
            FIIcon *icon = [FIEntypoIcon dotIcon];
            UIImage *image = [icon imageWithBounds:CGRectMake(0, 0, 5, 5) color:[UIColor grayColor]];
            cell.imageView.image = image;
            break;
        }
        case 2: {
            cell.textLabel.text = @"Settings";
            FIIcon *icon = [FIEntypoIcon cogIcon];
            UIImage *image = [icon imageWithBounds:CGRectMake(0, 0, 20, 20) color:[UIColor grayColor]];
            cell.imageView.image = image;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        default:
            break;
    }

}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section==1) {
        return @"Blog";
    } else {
        return @"";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return subscribeFeeds.count;
            break;
        case 2:
            return 1;
            break;
        default:
            return 0;
            break;
    }

}

#pragma mark -
#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: {
            
            [self.sideMenuViewController closeMenuAnimated:YES completion:^(BOOL finished) {
                [self loadLZLikeMainViewController];
            }];
            break;
        }
        case 1: {
            [self.sideMenuViewController closeMenuAnimated:YES completion:^(BOOL finished) {
                [self reloadMainViewControllerAtIndexPath:indexPath];
            }];
            break;
        }
        case 2: {
            [self.sideMenuViewController closeMenuAnimated:YES completion:^(BOOL finished) {
                LZSettingTableViewController *settingVC = [[LZSettingTableViewController alloc]init];
                UINavigationController *nc = [[UINavigationController alloc]initWithRootViewController:settingVC];
                
                settingVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                [self presentViewController:nc animated:YES
                                 completion:nil];
                                                    
            }];
        }
        default:
            break;
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"subscribeFeeds.count:%ld", subscribeFeeds.count);
        LZSubscribeFeed *delFeed = subscribeFeeds[indexPath.row];
        NSString *delFeedId = delFeed.feedId;
        [LZManagedObjectManager deleteSubscribeFeedWithFeedId:delFeed.feedId withContext:__managedObjectContextOfAppDelegate];

        // Remove the feed in Parse cloud
        PFQuery *query = [PFQuery queryWithClassName:@"SubscribeFeeds"];
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        PFObject *userFeeds = [[query findObjects] objectAtIndex:0];
        [query getObjectInBackgroundWithId:userFeeds.objectId block:^(PFObject *object, NSError *error) {


            dispatch_async(dispatch_queue_create("com.luzheng1208.asyncQueue", NULL), ^{
                for (NSDictionary *feed in object[@"feeds"]) {
                    if ([feed[@"feedId"] isEqualToString:delFeedId]) {
                        [object removeObject:feed forKey:@"feeds"];
                        break;
                    }
                }
                [object saveInBackground];

            });

        }];
        
        [subscribeFeeds removeObjectAtIndex:indexPath.row];
        [feedsTitleTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void) loadLZLikeMainViewController {
    NSLog(@"%@:%@", THIS_FILE, THIS_METHOD);
  
    LZLikeMainTableViewController *likeMainViewController = [[LZLikeMainTableViewController alloc]initWithNibName:nil bundle:nil];
    UINavigationController *nvController = [[UINavigationController alloc]initWithRootViewController:likeMainViewController];
   
    [[__appDelegate sideMenuViewController] setMainViewController:nvController animated:NO closeMenu:YES];
}


- (void)reloadMainViewControllerAtIndexPath:(NSIndexPath *)indexPath
{
    LZMainViewController *mainViewController;
    UINavigationController *nvController = (UINavigationController *) self.sideMenuViewController.mainViewController;
    mainViewController = [nvController.viewControllers objectAtIndex:0];
    
    if ([mainViewController isKindOfClass:[LZMainViewController class]]) {
        mainViewController = [nvController.viewControllers objectAtIndex:0];
    } else {
        //mainViewController = [[LZMainViewController alloc]initWithNibName:nil bundle:nil];
        mainViewController = [__appDelegate mainViewController];
        nvController = [[UINavigationController alloc]initWithRootViewController:mainViewController];
        [[__appDelegate sideMenuViewController] setMainViewController:nvController animated:NO closeMenu:YES];
    }

    NSURL *feedURL;
    if (indexPath.section==1) {
       LZSubscribeFeed *feed = [subscribeFeeds objectAtIndex:indexPath.row];
        feedURL = [NSURL URLWithString:feed.feedId];
    }
    
    switch (indexPath.section) {
        case 0:
            break;
        case 1:
            [mainViewController parseFeedURL:feedURL];
            break;
        default:
            break;
    }
    
}


- (void)addWebsiteBtnPressed
{

    UITableViewController *resultTableVC = [[UITableViewController alloc]initWithStyle:UITableViewStylePlain];
    LZFeedSearchViewController *searchVC = [[LZFeedSearchViewController alloc]initWithSearchResultsController:resultTableVC];
    
    resultTableVC.tableView.delegate = searchVC;
    resultTableVC.tableView.dataSource = searchVC;
    
    [searchVC setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:searchVC animated:YES completion:nil];
    
    
}

- (void)subscribeBtnPressed
{
    if ([subscribeURLTextField.text isEqualToString:@""]) {
        

        subscribeBtn.alpha = 0.0;
        addWebsiteBtn.alpha = 1.0;
        [UIWebView animateWithDuration:1.0f animations:^{
            addWebsiteBtn.frame = CGRectMake(10.0f, 124.0f, 228.0f, 30.0f);
            subscribeURLTextField.alpha = 0.0;

        }];
        subscribeBtn.frame = addWebsiteBtn.frame;

    }
    else{
        [self.sideMenuViewController closeMenuAnimated:YES
                                            completion:^(BOOL finished) {
                                                if (finished) {
                                                    UINavigationController *nvController = (UINavigationController*) self.sideMenuViewController.mainViewController;
                                                    LZMainViewController *mainViewController = [nvController.viewControllers objectAtIndex:0];
                                                    mainViewController.feedURLString = subscribeURLTextField.text;

                                                    [mainViewController parseFeedURL:[NSURL URLWithString:subscribeURLTextField.text]];
                                                    
                                                    
                                                }
                                            }];
    }
}


# pragma mark - UITextFieldDelegate
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    self.rssURL = [[NSString alloc] initWithString:textField.text];
    NSLog(@"rssURL:%@",self.rssURL);
    return NO;
}

@end
