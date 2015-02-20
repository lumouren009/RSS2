//
//  LoginViewController.h
//  RSS2
//
//  Created by luzheng1208 on 15/2/19.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LZLoginViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *userNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *pwdTextField;
@property (strong, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong, nonatomic) IBOutlet UILabel *signUpBtn;

@end
