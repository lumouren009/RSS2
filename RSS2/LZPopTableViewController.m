//
//  popTableViewController.m
//  RSS2
//
//  Created by luzheng1208 on 15/2/13.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import "LZPopTableViewController.h"

@interface LZPopTableViewController () <WYPopoverControllerDelegate>

@end

@implementation LZPopTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[self.tableView setfra:CGRect(0, 0, self.tableView.frame.size.width/2, self.tableView.rowHeight*2)];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kTableViewCellIdentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTableViewCellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:{
            cell.textLabel.text = @"List View";
            FIIcon *icon = [FIEntypoIcon listIcon];
            UIImage *image = [icon imageWithBounds:CGRectMake(0, 0, 20, 20) color:[UIColor grayColor]];
            cell.imageView.image = image;
            break;
        }
        case 1:{
            cell.textLabel.text = @"Image View";
            FIIcon *icon = [FIEntypoIcon numberedListIcon];
            UIImage *image = [icon imageWithBounds:CGRectMake(0, 0, 20, 20) color:[UIColor grayColor]];
            cell.imageView.image = image;
            break;
        }
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [[NSNotificationCenter defaultCenter]postNotificationName:kChangeMainViewLayoutNotification object:nil userInfo:@{@"layout":[NSNumber numberWithInt:LZLayoutList]}];
            break;
        case 1:
            [[NSNotificationCenter defaultCenter]postNotificationName:kChangeMainViewLayoutNotification object:nil userInfo:@{@"layout":[NSNumber numberWithInt:LZLayoutView]}];
            break;
        default:
            break;
    }

}



@end
