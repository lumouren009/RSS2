//
//  LZSignupViewController.m
//  RSS2
//
//  Created by luzheng1208 on 15/2/20.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import "LZSignupViewController.h"

@interface LZSignupViewController ()
//@property (nonatomic, strong) NSString *usernameString;
//@property (nonatomic, strong) NSString *pwdString;
//@property (nonatomic, strong) NSString *emailString;


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
    PFUser *user = [PFUser user];
    user.username = self.userNameTextField.text;
    user.password = self.pwdTextField.text;
    user.email = self.emailTextField.text;
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:activityIndicatorView];
    [activityIndicatorView startAnimating];
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [activityIndicatorView stopAnimating];
        if (!error) {
            [self dismissViewControllerAnimated:YES completion:nil];
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
