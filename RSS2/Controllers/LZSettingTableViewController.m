//
//  LZSettingTableViewController.m
//  RSS2
//
//  Created by luzheng1208 on 15/2/19.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import "LZSettingTableViewController.h"
#import "LZLoginViewController.h"

@interface LZSettingTableViewController () <UIAlertViewDelegate>
@property (nonatomic, strong) NSIndexPath *loginStatusIndexPath;
@end

@implementation LZSettingTableViewController
@synthesize loginStatusIndexPath;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Navigation item
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(doneBtnPressed:)];
    
    // Setup notification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateLoginStatusRow) name:kLoginSuccessNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCellIdentifier];

    if (cell==nil) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTableViewCellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:(NSIndexPath *)indexPath];
    
    return cell;
}

#pragma mark - private methods 

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            loginStatusIndexPath = indexPath;
            PFUser *currentUser = [PFUser currentUser];
            if (currentUser) {
                cell.textLabel.text = NSLocalizedString(@"Log out", nil);
            } else {
                cell.textLabel.text = NSLocalizedString(@"Log in", nil);
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 1:{
            UIButton *whiteBkgBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            whiteBkgBtn.frame =  CGRectMake(15, 15, kScreenWidth/2, 30);
            whiteBkgBtn.backgroundColor = [UIColor whiteColor];
            [cell.contentView addSubview:whiteBkgBtn];
            break;
        }
        
        case 2: {
            cell.textLabel.text = NSLocalizedString(@"Clear cache", nil);
            break;
        }
         
        default:
            break;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    switch (indexPath.section) {
        case 0: {
            
            if ([cell.textLabel.text isEqualToString:NSLocalizedString(@"Log in", nil)]) {
                LZLoginViewController *loginVC = [[LZLoginViewController alloc]init];
                loginVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                [self presentViewController:[[UINavigationController alloc ]initWithRootViewController:loginVC ] animated:YES completion:nil];
                

            } else {
                [[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Log out", nil) message:NSLocalizedString(@"Are you sure to log out and remove all the feeds from your iPhone?", nil)  delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Log out", nil), nil]show];
                
                
                
            }
            break;
        }
        default:
            break;
    }
}

- (void)doneBtnPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateLoginStatusRow {
    DDLogVerbose(@"%@.%@",THIS_FILE, THIS_METHOD);  
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[loginStatusIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

#pragma mark - UIAlterView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSLog(@"Log out button pressed!");
        [PFUser logOut];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[loginStatusIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}


@end
