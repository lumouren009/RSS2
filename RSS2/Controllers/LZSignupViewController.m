//
//  LZSignupViewController.m
//  RSS2
//
//  Created by luzheng1208 on 15/2/20.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import "LZSignupViewController.h"

@interface LZSignupViewController ()
@end

@implementation LZSignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pwdTextField.secureTextEntry = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelBtnPressed:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signupBtnPressed:(id)sender {
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:activityIndicatorView];
    [activityIndicatorView startAnimating];
    PFUser *signupUser;
    signupUser = [PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]] ? [PFUser currentUser] : [PFUser user];
    signupUser.username = self.userNameTextField.text;
    signupUser.password = self.pwdTextField.text;
    signupUser.email = self.emailTextField.text;
    signupUser[@"anonymous"]  = [NSNumber numberWithBool:[PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]];
    
    __unsafe_unretained LZSignupViewController *__self = self;
    
    [signupUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [PFUser logInWithUsernameInBackground:signupUser.username password:signupUser.password block:^(PFUser *user, NSError *error) {
                [activityIndicatorView stopAnimating];
                if (!error) {
                    NSLog(@"Log in successfully!!");
                    if ([user[@"anonymous"]boolValue]) {
                        PFObject *subscribeFeeds = [PFObject objectWithClassName:@"SubscribeFeeds"];
                        subscribeFeeds[@"user"] = [PFUser currentUser];
                        subscribeFeeds[@"feeds"] = [[NSMutableArray alloc]init];
                        [subscribeFeeds save];
                    }
                    
                    [__self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
                } else {
                    NSLog(@"error occurs in login:%@", [error localizedDescription]);
                }
            }];
        } else {
            [[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Login error", nil)
                                       message:NSLocalizedString([error localizedDescription], nil)
                                      delegate:self
                             cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:nil] show];
        }
    }];
    
}

- (void)cancelBtnPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
