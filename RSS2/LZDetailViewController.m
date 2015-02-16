//
//  LZDetailViewController.m
//  RSSReader
//
//  Created by luzheng1208 on 15/2/4.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import "LZDetailViewController.h"
#import "NSString+HTML.h"

#import "constants.h"
#import "LZLikeItem.h"
#import "AppDelegate.h"
#import "LZItem.h"
#import <DDTTYLogger.h>
#import <FontasticIcons.h>
#import <MBProgressHUD.h>
#import "LZToolbar.h"
#import "LZFontConfigPane.h"



@interface LZDetailViewController () <UIGestureRecognizerDelegate, UIWebViewDelegate, UIScrollViewDelegate, LZFontConfigPaneDelegate, LZToolBarDelegate>

@property (nonatomic, assign) BOOL isFontChangeViewDisplayed;
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) CGFloat screenHeight;
@property (nonatomic, strong) LZFontConfigPane *fontSizeChangeView;
@property (nonatomic, strong) LZToolbar *toolbar;
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, assign) NSInteger globalFontSize;
@property (nonatomic, assign) CGFloat fontRatio;
@property (nonatomic, assign) NSInteger textBackgroundColorTag;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, assign) BOOL isBookmarked;
@property (nonatomic, assign) NSInteger nPagesViewd;
@property (nonatomic, strong) NSMutableArray *blogWebViews;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger itemCount;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) UIWebView *currentBlogWebView;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) LZItem *currentDisplayedItem;


- (void)loadVisiblePages;
- (void)loadPage:(NSInteger)page;
- (void)purgePage:(NSInteger)page;

@end

@implementation LZDetailViewController
@synthesize feedItems;
@synthesize currentItemIndex;
@synthesize blogWebViews, scrollView;
@synthesize itemCount;
@synthesize formatter;
@synthesize currentBlogWebView;
@synthesize currentPage;
@synthesize currentDisplayedItem;
@synthesize currentFeedItem, itemTitle, dateString, summaryString, contentString, feedTitle, identifierString;
@synthesize fontSizeChangeView, toolbar;
@synthesize screenHeight,screenWidth;
@synthesize isFontChangeViewDisplayed;
@synthesize userDefaults;
@synthesize globalFontSize, fontRatio, textBackgroundColorTag;
@synthesize managedObjectContext, appDelegate;
@synthesize isBookmarked;
@synthesize nPagesViewd;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up env variables and current feed item attrs
    [self setupEnvVariables];
    
    // Setup UI
    [self setupNavigationBar];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    
    // Initialize array to hold web views
    itemCount = feedItems.count; NSLog(@"itemCount:%ld", (long)itemCount);
    blogWebViews = [[NSMutableArray alloc]init];
    for (NSInteger i=0; i<itemCount; i++) {
        [blogWebViews addObject:[NSNull null]];
    }
    
    // Initialize ScrollView
    scrollView = [[UIScrollView alloc]init];
    self.scrollView.delegate = self;
    [scrollView setScrollEnabled:NO];
    [self.view addSubview:scrollView];
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    globalFontSize = [(NSNumber *)[userDefaults objectForKey:kGlobalFontSize] integerValue];
    textBackgroundColorTag = [(NSNumber *)[userDefaults objectForKey:kTextBackgroundColorTag] integerValue];
    
    self.scrollView.frame = CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height-60);
    self.scrollView.contentSize  = CGSizeMake(itemCount*screenWidth, screenHeight);
    self.scrollView.contentOffset = CGPointMake(currentItemIndex*screenWidth,0);
    [self loadVisiblePages];

}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [userDefaults setObject:[NSNumber numberWithInteger:globalFontSize] forKey:kGlobalFontSize];
    [userDefaults setObject:[NSNumber numberWithInteger:textBackgroundColorTag] forKey:kTextBackgroundColorTag];
    [userDefaults synchronize];
}

#pragma mark - 
#pragma mark Private Methods

- (void)loadVisiblePages {
    
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger page = (NSInteger)floor((self.scrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    NSLog(@"page:%ld", (long)page);
    
    // Work out which pages you want to load
    NSInteger firstPage = page - 1;
    NSInteger lastPage = page + 1;
    
    // Purge anything before the first page
    for (NSInteger i=0; i<firstPage; i++) {
        [self purgePage:i];
    }
    
    // Load pages in our range
    for (NSInteger i=firstPage; i<=lastPage; i++) {
        [self loadPage:i];
    }
    
    // Purge anything after the last page
    for (NSInteger i=lastPage+1; i<itemCount; i++) {
        [self purgePage:i];
    }
    
    currentBlogWebView = [self.blogWebViews objectAtIndex:page];
    currentPage = page;
    currentDisplayedItem = [self.feedItems objectAtIndex:currentPage];
    // Setup tap & swipe gesture
    
    [toolbar removeFromSuperview];
    [fontSizeChangeView removeFromSuperview];
    [self setupGestures];
    [self setupToolBar];
    [self setupFontView];
    
}

- (void)loadPage:(NSInteger)page {
    NSLog(@"%@:page:%ld",THIS_METHOD,(long)page);
    if (page < 0 || page >= itemCount) {
        return;
    }
    
    UIView *pageView = [self.blogWebViews objectAtIndex:page];
    if ((NSNull*)pageView == [NSNull null]) {

        CGRect frame = self.scrollView.bounds;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0.0f;
    
        UIWebView *newBlogView = [[UIWebView alloc]initWithFrame:frame];
        
        [self loadWebView:newBlogView withItem:[self.feedItems objectAtIndex:page]];
        [self.scrollView addSubview:newBlogView];
        
        
        [self.blogWebViews replaceObjectAtIndex:page withObject:newBlogView];
    }
}

- (void)purgePage:(NSInteger)page {
    if (page < 0 || page >= itemCount) {
        // If it's outside the range of what you have to display, then do nothing
        return;
    }
    
    // Remove a page from the scroll view and reset the container array
    UIView *pageView = [self.blogWebViews objectAtIndex:page];
    if ((NSNull*)pageView != [NSNull null]) {
        [pageView removeFromSuperview];
        [self.blogWebViews replaceObjectAtIndex:page withObject:[NSNull null]];
    }
}

#pragma mark - Scroll View delegate

- (void)setupEnvVariables {
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    managedObjectContext = appDelegate.managedObjectContext;
    
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    globalFontSize = [(NSNumber *)[userDefaults objectForKey:kGlobalFontSize] integerValue];
    textBackgroundColorTag = [(NSNumber *)[userDefaults objectForKey:kTextBackgroundColorTag] integerValue];
    
    nPagesViewd = 0;
    isFontChangeViewDisplayed = NO;
    currentPage = currentItemIndex;
    if (OBJ_IS_NIL([LZManagedObjectManager getLikeItemByIdentifier:[(LZItem *)feedItems[currentPage] identifier] withContext:managedObjectContext])) {
        isBookmarked = NO;
    } else {
        NSLog(@"LZItem:%@",[[LZManagedObjectManager getItemByIdentifier:[(LZItem *)feedItems[currentPage] identifier] withContext:managedObjectContext]description ]);
        NSLog(@"LZLikeItem:%@", [[LZManagedObjectManager getLikeItemByIdentifier:[(LZItem *)feedItems[currentPage] identifier] withContext:managedObjectContext]description]);
        isBookmarked = YES;
    }
    // Date and time formatter
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
}

- (void)setupGestures {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onSingleTap)];
    tap.delegate = self;
    [currentBlogWebView addGestureRecognizer:tap];
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeUpAndDown:)];
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [currentBlogWebView addGestureRecognizer:swipeUp];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeUpAndDown:)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [currentBlogWebView addGestureRecognizer:swipeDown];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeftAndRight:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [currentBlogWebView addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeftAndRight:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [currentBlogWebView addGestureRecognizer:swipeRight];

}

- (void)setupNavigationBar {
    [self.navigationController.navigationBar setHidden:NO];
    
    // Left blog view button
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    leftButton.frame = CGRectMake(0, 0, 23, 23);
    FIIcon *icon = [FIEntypoIcon chevronThinLeftIcon];
    
    FIIconLayer *layer = [FIIconLayer new];
    layer.icon = icon;
    layer.frame = leftButton.bounds;
    layer.iconColor = [UIColor blackColor];
    [leftButton.layer addSublayer:layer];
    [leftButton addTarget:self action:@selector(backToPreviousBlog) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftBlogBtn = [[UIBarButtonItem alloc]initWithCustomView:leftButton];

    // Right blog view button
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    rightButton.frame = CGRectMake(0, 0, 23, 23);
    icon = [FIEntypoIcon chevronThinRightIcon];
    
    layer = [FIIconLayer new];
    layer.icon = icon;
    layer.frame = rightButton.bounds;
    layer.iconColor = [UIColor blackColor];
    [rightButton.layer addSublayer:layer];
    [rightButton addTarget:self action:@selector(forwardToNextBlog) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightBlogBtn = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItems = @[rightBlogBtn, leftBlogBtn];

}

- (void)setupToolBar {
    DDLogVerbose(@"%@:%@", THIS_FILE, THIS_METHOD);
    toolbar = [[LZToolbar alloc]initWithFrame:CGRectMake(0,self.view.frame.size.height-44, self.view.frame.size.width, 44)];
    if ([[[LZManagedObjectManager getItemByIdentifier:currentDisplayedItem.identifier withContext:managedObjectContext] isBookmarked] boolValue]) {

        toolbar.bookmarkBtn.image  = [[FIEntypoIcon starIcon] imageWithBounds:CGRectMake(0, 0, 23, 23) color:[UIColor colorWithRed:0.99 green:0.87 blue:0.18 alpha:1.0]];
        toolbar.bookmarkBtn.tintColor = [UIColor colorWithRed:0.99 green:0.99 blue:0.38 alpha:1.0];
    }
    toolbar.delegate = self;
    [self.view addSubview:toolbar];
}


- (void)setupFontView {
    NSLog(@"%@.%@", THIS_FILE, THIS_METHOD);
    fontSizeChangeView = [[LZFontConfigPane alloc]initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 170)];
    fontSizeChangeView.delegate = self;
    [self.view addSubview:fontSizeChangeView];
    
}


- (UIButton *)backgroundColorButtonWithColor:(UIColor*)color andTag:(NSInteger)tag{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.layer.cornerRadius = 2;
    button.backgroundColor = color;
    button.tag = tag;
    return button;
}


- (void)loadWebView:(UIWebView *)webView withItem:(LZItem *)item {
    NSString *cssTypeString = [NSString stringWithFormat:@"<html> \n"
                               "<style type='text/css'> \n"
                               "img { max-width: 100%%; width: auto; height: auto; }\n"
                               "h1 { font-size: %@px;} \n"
                               "h2 { font-size: %@px;} \n"
                               "p { font-size: %@px; } \n"
                               "a { color:#666666; text-decoration:none; border-bottom:1px dashed #808080} \n"
                               "table { max-width: 100%%; width: auto; } \n"
                               "html { width: 100%%; max-width: 100%% overflow: hidden; } \n"
                               "div { max-width: 100%%;} \n"
                               "pre { white-space:pre-wrap;} \n"
                               "p.date { font-size: %@px; }"
                               "body { color:#888888 }</style>", @(23), @(18), @(15), @(12)];
    
    
    
    NSString *aItemTitle = item.title ? [item.title stringByConvertingHTMLToPlainText] : @"[No Title]";;
    NSString *aDateString = [formatter stringFromDate:item.date];;
    NSString *aContentString = item.content ? item.content : @"[No Content]";;
    NSString *aSummaryString = item.summary ? item.summary : @"[No Summary]";;


    
    
    NSString *htmlData  = [NSString stringWithFormat:
                           @"<h1>%@</h1><p class='date'>%@ / %@</p> %@", aItemTitle, self.feedTitle, aDateString, item.content.length > item.summary.length ? aContentString : aSummaryString];
    webView.backgroundColor =  [LZSystemConfig themeColorWithTag:textBackgroundColorTag];
    [webView loadHTMLString:[cssTypeString stringByAppendingString:htmlData] baseURL:nil];
    webView.delegate = self;
    [webView setOpaque:NO];
    
}

#pragma mark -
#pragma mark UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    DDLogVerbose(@"%@:%@", THIS_FILE, THIS_METHOD);
    if ([[[request URL]scheme]isEqual:@"http"] || [[[request URL]scheme]isEqual:@"https"]) {
        toolbar.leftBtnItem.enabled = YES;
        UIButton *leftButton = (UIButton *)toolbar.leftBtnItem.customView;
        FIIconLayer *layer = (FIIconLayer *)[leftButton.layer.sublayers lastObject];
        layer.iconColor = [UIColor blackColor];
        [toolbar setItems:@[toolbar.fixedSpace, toolbar.leftBtnItem, toolbar.flexibleSpace, toolbar.fontBtn, toolbar.flexibleSpace, toolbar.shareBtn, toolbar.fixedSpace]];
    } else {
        toolbar.leftBtnItem.enabled = NO;
        UIButton *leftButton = (UIButton *)toolbar.leftBtnItem.customView;
        FIIconLayer *layer = (FIIconLayer *)[leftButton.layer.sublayers lastObject];
        layer.iconColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
        [toolbar setItems:@[toolbar.fixedSpace, toolbar.leftBtnItem, toolbar.flexibleSpace, toolbar.bookmarkBtn, toolbar.flexibleSpace, toolbar.fontBtn, toolbar.flexibleSpace, toolbar.shareBtn, toolbar.fixedSpace]];
    }
    return YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    DDLogVerbose(@"%@:%@", THIS_FILE, THIS_METHOD);

    [self reloadWebViewWithFontSize:globalFontSize];
    
}

- (void)reloadWebViewWithFontSize:(NSInteger)fontSize {

    NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%ld%%'",
                          (long)fontSize];
    
    [currentBlogWebView stringByEvaluatingJavaScriptFromString:jsString];
}

#pragma mark - LZFontConfigPane delegate methods


- (void)reduceFontBtnPressed {
    if(globalFontSize > 60) {
        globalFontSize = globalFontSize - 10;
        [self reloadWebViewWithFontSize:globalFontSize];
    }

}


- (void)enlargeFontBtnPressed {
    if(globalFontSize <160) {
        globalFontSize = globalFontSize + 10;
        [self reloadWebViewWithFontSize:globalFontSize];
    }
}

- (void)setThemeColor:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeThemeColorNotification object:nil userInfo:@{@"themeColorTag":[NSNumber numberWithInteger:sender.tag]}];
    NSUInteger tag = sender.tag;
    UIColor *themeColor = [LZSystemConfig themeColorWithTag:tag];
    [currentBlogWebView setBackgroundColor:themeColor];
    
    if (currentPage>0) {
        [[blogWebViews objectAtIndex:currentPage-1] setBackgroundColor:themeColor];
    }
    if (currentPage<itemCount-1) {
        [[blogWebViews objectAtIndex:currentPage+1] setBackgroundColor:themeColor];
    }
    
    textBackgroundColorTag = tag;
}

- (void)changeScreenBrightness:(UISlider *)sender {
    [[UIScreen mainScreen] setBrightness:sender.value];
}

#pragma mark - LZToolBar delegate methods
- (void)backToPreviousPage {
    DDLogVerbose(@"%@:%@", THIS_FILE, THIS_METHOD);
    nPagesViewd -= 2;

    if ([currentBlogWebView canGoBack]) {
        [currentBlogWebView goBack];
    } else {
        [self loadWebView:currentBlogWebView withItem:[feedItems objectAtIndex:currentPage]];
    }
}

- (void)bookmarkButtonPressed {
    LZItem *item = [LZManagedObjectManager getItemByIdentifier:currentDisplayedItem.identifier withContext:managedObjectContext];
    
    if (!item.isBookmarked.boolValue) {
        item.isBookmarked = [NSNumber numberWithBool:YES];
        [LZManagedObjectManager insertIntoLikeDBWithItem:item
                                            andFeedTitle:feedTitle
                                             withContext:managedObjectContext];
        FIEntypoIcon *icon = [FIEntypoIcon starIcon];
        UIImage *starImage = [icon imageWithBounds:CGRectMake(0, 0, 23, 23) color:[UIColor colorWithRed:0.99 green:0.87 blue:0.18 alpha:1.0]];
        self.toolbar.bookmarkBtn.image = starImage;
        self.toolbar.bookmarkBtn.tintColor = [UIColor colorWithRed:0.99 green:0.99 blue:0.38 alpha:1.0];
    
        // Show text Hud
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];

        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"已加喜欢";
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;

        [hud hide:YES afterDelay:1];
        NSLog(@"Bookmarked!!!!");
    } else {
        item.isBookmarked = [NSNumber numberWithBool:NO];
        [self removeLZLikeItem];
        self.toolbar.bookmarkBtn.image = [UIImage imageNamed:@"ic_star_w"];
        self.toolbar.bookmarkBtn.tintColor = [UIColor blackColor];
        //Show text hud
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];

        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"取消喜欢";
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:1];
        NSLog(@"No bookmark!!!");

    }
}


- (void)fontButtonPressed {
    [UIView animateWithDuration:0.2f animations:^{
        fontSizeChangeView.frame = CGRectMake(0, kScreenHeight-170, screenWidth, 170);
    }];
    isFontChangeViewDisplayed = YES;
}

- (void)shareButtonPressed {
    NSMutableArray *sharingItems = [[NSMutableArray alloc]init];
    NSString *text = [NSString stringWithFormat:@"%@ %@ via RSSReader", itemTitle, identifierString];
    [sharingItems addObject:text];

    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
    
}

- (void)removeLZLikeItem {
    LZLikeItem *likeItem = [LZManagedObjectManager getLikeItemByIdentifier:[(LZItem*)feedItems[currentPage] identifier] withContext:managedObjectContext];
    if (likeItem==nil) {
        NSLog(@"%@:likeItem is nil", THIS_METHOD);
    }
    if (likeItem) {
        [managedObjectContext deleteObject:likeItem];
        [managedObjectContext save:nil];
    }

}

#pragma mark -
#pragma mark Recognizer methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch locationInView:self.view].y < screenHeight -150 && isFontChangeViewDisplayed == YES) {
        
        [UIView animateWithDuration:0.2 animations:^{
            fontSizeChangeView.frame = CGRectMake(0, screenHeight, screenWidth, 170);
        }];
    }
  
    return YES;
}

- (void)onSingleTap {
    
}

- (void)swipeUpAndDown:(UISwipeGestureRecognizer *)gestureRecognizer {
    NSLog(@"%@ %@", THIS_FILE, THIS_METHOD);
    NSLog(@"Swipe Received");
    
    if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionUp) {
        [UIView animateWithDuration:0.5f animations:^{
            toolbar.frame = CGRectOffset(toolbar.frame, 0, toolbar.frame.size.height);
        }];
    } else if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionDown) {
        [UIView animateWithDuration:0.5f animations:^{
            toolbar.frame = CGRectOffset(toolbar.frame, 0, 0-toolbar.frame.size.height);
        }];
    }
}

- (void)swipeLeftAndRight:(UISwipeGestureRecognizer *)gestureRecognizer {
    NSLog(@"%@ %@", THIS_FILE, THIS_METHOD);
    NSLog(@"Swipe Receieved");
    
    if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        if (currentPage<itemCount) {
            currentBlogWebView.frame = CGRectOffset(currentBlogWebView.frame, screenWidth, 0);
        }
    } else if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        if (currentPage>0) {
            currentBlogWebView.frame = CGRectOffset(currentBlogWebView.frame, 0-screenWidth, 0);
        }
        
    }
}


#pragma mark - Navigation bar item action
- (void)backToPreviousBlog {
    [scrollView setScrollEnabled:YES];
    
    [UIView animateWithDuration:0.2f animations:^{
        if (currentPage > 0) {
            fontSizeChangeView.frame = CGRectMake(0, screenHeight, screenWidth, 170);
            scrollView.contentOffset = CGPointMake((currentPage-1)*screenWidth, 0);
        }
    }];
    
    [self loadVisiblePages];
    [scrollView setScrollEnabled:NO];
    
}

- (void)forwardToNextBlog {
    [scrollView setScrollEnabled:YES];
    [UIView animateWithDuration:0.2f animations:^{
        if (currentPage < itemCount-1) {
            fontSizeChangeView.frame = CGRectMake(0, screenHeight, screenWidth, 170);
            scrollView.contentOffset = CGPointMake((currentPage+1)*screenWidth, 0);
        }
    }];
    
    [self loadVisiblePages];
    [scrollView setScrollEnabled:NO];
    
}

@end
