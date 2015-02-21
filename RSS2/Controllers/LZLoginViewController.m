//
//  LoginViewController.m
//  RSS2
//
//  Created by luzheng1208 on 15/2/19.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import "LZLoginViewController.h"
#import "LZSettingTableViewController.h"
#import "LZSignupViewController.h"

@interface LZLoginViewController ()
@property (nonatomic, strong) NSString *userNameString;
@property (nonatomic, strong) NSString *pwdString;
@property (nonatomic, strong) LZSettingTableViewController *settingVC;
@end

@implementation LZLoginViewController
@synthesize userNameString;
@synthesize pwdString;
@synthesize settingVC;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pwdTextField.secureTextEntry = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelBtnPressed:)];
    

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    settingVC = (LZSettingTableViewController *)[[(UINavigationController *)self.presentingViewController viewControllers] objectAtIndex:0];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)loginBtnPressed:(UIButton *)sender {
    DDLogVerbose(@"%@,%@", THIS_FILE, THIS_METHOD);
    userNameString = self.userNameTextField.text;
    pwdString = self.pwdTextField.text;
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:activityIndicatorView];
    [activityIndicatorView startAnimating];
    [PFUser logInWithUsernameInBackground:userNameString password:pwdString block:^(PFUser *user, NSError *error) {
        [activityIndicatorView stopAnimating];
        if (user) {

            [self dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter]postNotificationName:kLoginSuccessNotification object:nil];
            }];
            // Save user data to DB
            dispatch_async(dispatch_queue_create("com.luzheng1208.syncQueue", NULL), ^{
                PFQuery *query = [PFQuery queryWithClassName:@"SubscribeFeeds"];
                [query whereKey:@"user" equalTo:[PFUser currentUser]];
                if ([[query findObjects] count]==0) {
                    PFObject *subscribeFeeds = [PFObject objectWithClassName:@"SubscribeFeeds"];
                    subscribeFeeds[@"user"] = [PFUser currentUser];
                    subscribeFeeds[@"feeds"] = [[NSMutableArray alloc]init];
                    [subscribeFeeds save];
                } else {
                    PFObject *userFeeds = [[query findObjects] objectAtIndex:0];
                    for (NSDictionary *feed in userFeeds[@"feeds"]) {
                        [LZManagedObjectManager insertIntoSubscribeFeedDBWithTitle:feed[@"feedTitle"] andFeedId:feed[@"feedId"]];
                    }
                    NSError *error;
                    if (![__managedObjectContextOfAppDelegate save:&error]) {
                        NSLog(@"%@,%@:Import subscribeFeeds failed:%@", THIS_FILE, THIS_METHOD, error);
                    }
                    [[NSNotificationCenter defaultCenter]postNotificationName:kUpdateSubscribeFeedListNotification object:nil];
                }
                
                
            });
            
        } else {
            [[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Login error", nil)
                                      message:NSLocalizedString([error localizedDescription], nil)
                                     delegate:self
                            cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:nil] show];
            
        }
    }];
}


- (IBAction)signUpBtnPressed:(id)sender {
    DDLogVerbose(@"%@,%@", THIS_FILE, THIS_METHOD);
    LZSignupViewController *signupVC = [[LZSignupViewController alloc]init];
    signupVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:[[UINavigationController alloc]initWithRootViewController:signupVC] animated:YES completion:nil];
}

- (void)cancelBtnPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
