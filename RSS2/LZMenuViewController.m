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
#import "AppDelegate.h"
#import "LZFeedInfo.h"
#import "constants.h"
#import "LZSubscribeTextField.h"
#import "LZLikeMainTableViewController.h"
#import "LZFeedSearchViewController.h"



static NSString * const kTableViewCellIndentifier = @"com.luzheng.LZMenuViewController.sampleCell";

@interface LZMenuViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) NSString *rssURL;

@property (nonatomic, strong) LZSubscribeTextField *subscribeURLTextField;

@property (nonatomic, strong) UIButton *addWebsiteBtn, *subscribeBtn;


@property (nonatomic, strong) UITableView *feedsTitleTableView;

@property (nonatomic, strong) NSMutableArray *feedURLArray;

@property (nonatomic, strong) NSArray *feedInfos;

@property (nonatomic, strong) AppDelegate *appDelegate;



@end

@implementation LZMenuViewController


@synthesize  subscribeURLTextField, addWebsiteBtn, subscribeBtn, appDelegate, feedsTitleTableView, managedObjectContext;

@synthesize feedInfos;


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
    
    // Fetch blog titles
    self.feedInfos = [self feedInfos];
    
    // Setup UI
    [self setupUI];
    
    // Setup observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFeedsTitleTableView:) name:kAddFeedNotification object:nil];
    
}

#pragma mark -
#pragma mark Private Methods

- (NSArray *) feedInfos
{
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LZFeedInfo" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return fetchedObjects;
}


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

- (void)updateFeedsTitleTableView:(NSNotification*)notification{
    self.feedInfos = [self feedInfos];
    NSLog(@"Observe the notification");
    [feedsTitleTableView reloadData];
}

#pragma mark - Table view data source
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCellIndentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTableViewCellIndentifier];
    }
    NSLog(@"feedInfo.count:%ld", (long)feedInfos.count);
    NSLog(@"indexPath.row:%ld", (long)indexPath.row);
    LZFeedInfo *info;
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = @"Read it Later";
            break;
        case 1:
            if (feedInfos.count>0 && indexPath.row >0) {
                info = (LZFeedInfo*)[feedInfos objectAtIndex:indexPath.row-1];
                cell.textLabel.text = info.title;
            }else {
                cell.textLabel.text = @"Blogs";
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            break;
        case 2:
            cell.textLabel.text = @"Settings";
        default:
            break;
    }
    return cell;
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
            return feedInfos.count+1;
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
        default:

            break;
    }


}

- (void) loadLZLikeMainViewController {
    NSLog(@"%@:%@", THIS_FILE, THIS_METHOD);
  
    LZLikeMainTableViewController *likeMainViewController = [[LZLikeMainTableViewController alloc]initWithNibName:nil bundle:nil];
    UINavigationController *nvController = [[UINavigationController alloc]initWithRootViewController:likeMainViewController];
   
    [appDelegate.sideMenuViewController setMainViewController:nvController animated:NO closeMenu:YES];
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
        mainViewController = appDelegate.mainViewController;
        nvController = [[UINavigationController alloc]initWithRootViewController:mainViewController];
        [appDelegate.sideMenuViewController setMainViewController:nvController animated:NO closeMenu:YES];
    }

    LZFeedInfo *info;
    if (indexPath.row > 0) {
        info = [feedInfos objectAtIndex:indexPath.row-1];
    }
    
    NSURL *feedURL = [NSURL URLWithString:info.url];
    
    switch (indexPath.section) {
        case 0:
            
            break;
        case 1:
            if (indexPath.row > 0) {
                [mainViewController parseFeedURL:feedURL];
            }
            break;
        default:
            break;
    }
    
}


- (void)addWebsiteBtnPressed
{
//    addWebsiteBtn.alpha = 0.0;
//    subscribeBtn.alpha = 1.0;
//    [UIView animateWithDuration:1.0f animations:^{
//        subscribeBtn.frame = CGRectMake(180.0f, 124.0f, 58.0f, 30.0f);
//        subscribeURLTextField.alpha = 1.0;
//    }];
//    addWebsiteBtn.frame = subscribeBtn.frame;
    
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
