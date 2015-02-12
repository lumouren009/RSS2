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



@interface LZDetailViewController () <UIGestureRecognizerDelegate, UIWebViewDelegate>

@property (nonatomic, assign) BOOL isFontChangeViewDisplayed;
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) CGFloat screenHeight;
@property (nonatomic, strong) UIView *fontSizeChangeView;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, assign) NSInteger globalFontSize;
@property (nonatomic, assign) CGFloat fontRatio;
@property (nonatomic, assign) NSInteger textBackgroundColorTag;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) UIBarButtonItem *bookmarkBtn, *leftBtnItem, *fontBtn, *shareBtn, *flexibleSpace, *fixedSpace;
@property (nonatomic, assign) BOOL isBookmarked;
@property (nonatomic, assign) NSInteger nPagesViewd;
@property (nonatomic, strong) UIWebView *blogWebView;
//@property (nonatomic, assign) int fontSize;

@end

@implementation LZDetailViewController
@synthesize feedItem, itemTitle, dateString, summaryString, contentString, feedTitle, identifierString;
@synthesize blogWebView, fontSizeChangeView, toolbar;
@synthesize screenHeight,screenWidth;
@synthesize isFontChangeViewDisplayed;
@synthesize userDefaults;
@synthesize globalFontSize, fontRatio, textBackgroundColorTag;
@synthesize managedObjectContext, appDelegate;
@synthesize bookmarkBtn, leftBtnItem, fontBtn, shareBtn, flexibleSpace, fixedSpace;
@synthesize isBookmarked;
@synthesize nPagesViewd;
//@synthesize fontSize;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialization

    appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    managedObjectContext = appDelegate.managedObjectContext;
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    screenHeight = [UIScreen mainScreen].bounds.size.height;
    isFontChangeViewDisplayed = NO;
    userDefaults = [NSUserDefaults standardUserDefaults];
    globalFontSize = [(NSNumber *)[userDefaults objectForKey:kGlobalFontSize] integerValue];
    textBackgroundColorTag = [(NSNumber *)[userDefaults objectForKey:kTextBackgroundColorTag] integerValue];
    nPagesViewd = 0;
    
    if (OBJ_IS_NIL([LZManagedObjectManager getLikeItemByIdentifier:feedItem.identifier withContext:managedObjectContext])) {
        isBookmarked = NO;
    } else {
        NSLog(@"LZItem:%@",[[LZManagedObjectManager getItemByIdentifier:feedItem.identifier withContext:managedObjectContext]description ]);
        NSLog(@"LZLikeItem:%@", [[LZManagedObjectManager getLikeItemByIdentifier:feedItem.identifier withContext:managedObjectContext]description]);
        isBookmarked = YES;
    }
    
    
    // Setup UI
    self.blogWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [self.view addSubview:blogWebView];
    [self.navigationController.navigationBar setHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self setupToolBar];
    [self setupFontView];

    // Setup gesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onSingleTap)];
    tap.delegate = self;
    [blogWebView addGestureRecognizer:tap];
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeUpAndDown:)];
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [blogWebView addGestureRecognizer:swipeUp];


    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeUpAndDown:)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [blogWebView addGestureRecognizer:swipeDown];


    // Date
    if (feedItem.date) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterMediumStyle];
        self.dateString = [formatter stringFromDate:feedItem.date];
    }
    
    // Summary
    if (feedItem.summary) {
        //self.summaryString = [item.summary stringByConvertingHTMLToPlainText];
        self.summaryString = feedItem.summary;
    } else {
        self.summaryString = @"[No Summary]";
    }
    
    // Content
    if (feedItem.content) {
        self.contentString = feedItem.content;
    } else {
        self.contentString = @"[No Content]";
    }
    
    // Title
    itemTitle = feedItem.title ? [feedItem.title stringByConvertingHTMLToPlainText] : @"[No Title]";
    
    // Identifier
    identifierString  = feedItem.identifier ? [feedItem.identifier stringByConvertingHTMLToPlainText] : @"[No identifier]";
    fontRatio = 1.0;
    [self loadBlogWebViewWithRatio:fontRatio];
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    globalFontSize = [(NSNumber *)[userDefaults objectForKey:kGlobalFontSize] integerValue];
    textBackgroundColorTag = [(NSNumber *)[userDefaults objectForKey:kTextBackgroundColorTag] integerValue];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [userDefaults setObject:[NSNumber numberWithInteger:globalFontSize] forKey:kGlobalFontSize];
    [userDefaults setObject:[NSNumber numberWithInteger:textBackgroundColorTag] forKey:kTextBackgroundColorTag];
    [userDefaults synchronize];
}


#pragma mark - 
#pragma mark Private Methods
- (void)setupToolBar {
    DDLogVerbose(@"%@:%@", THIS_FILE, THIS_METHOD);
    
    
    toolbar = [[UIToolbar alloc]init];
    toolbar.frame = CGRectMake(0, self.view.frame.size.height-75, [UIScreen mainScreen].bounds.size.width , 44);
    toolbar.translucent = NO;
    NSMutableArray *items = [[NSMutableArray alloc]init];
    
    
    // Left Arrow
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    leftButton.frame = CGRectMake(0, 0, 23, 23);
    FIIcon *icon = [FIEntypoIcon chevronThinLeftIcon];
    
    FIIconLayer *layer = [FIIconLayer new];
    layer.icon = icon;
    layer.frame = leftButton.bounds;
    layer.iconColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
    [leftButton.layer addSublayer:layer];
    [leftButton addTarget:self action:@selector(backToPreviousPage) forControlEvents:UIControlEventTouchUpInside];
    
    leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    leftBtnItem.enabled = NO;
   
    
    // Bookmark Button
    bookmarkBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", isBookmarked ? @"ic_star_y" : @"ic_star_w"]] style:UIBarButtonItemStylePlain target:self action:@selector(addToBookMarks)];
    if (!isBookmarked)
        bookmarkBtn.tintColor = [UIColor blackColor];
    else
        bookmarkBtn.tintColor = [UIColor colorWithRed:0.99 green:0.99 blue:0.38 alpha:1.0];

    
    fontBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"ic_font"] style:UIBarButtonItemStylePlain target:self action:@selector(changeFontSize)];
    fontBtn.tintColor = [UIColor blackColor];
    
    
    shareBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareBtnPressed)];
    shareBtn.tintColor = [UIColor blackColor];
    
    flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    fixedSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    [items addObjectsFromArray:@[fixedSpace, leftBtnItem, flexibleSpace, bookmarkBtn, flexibleSpace, fontBtn, flexibleSpace, shareBtn, fixedSpace]];
    
    
    [toolbar setItems:items];
    [self.view addSubview:toolbar];
}


- (void)setupFontView {
    
    fontSizeChangeView = [[UIView alloc]init];
    fontSizeChangeView.frame = CGRectMake(0, screenHeight, screenWidth, 170);
    [fontSizeChangeView setBackgroundColor:[UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0]];
    
    UIButton *reduceFontBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    reduceFontBtn.frame = CGRectMake(0, 50 , screenWidth/2, 30);
    [reduceFontBtn setBackgroundColor:[UIColor whiteColor]];
    [reduceFontBtn setTitle:@"-" forState:UIControlStateNormal];
    [reduceFontBtn addTarget:self action:@selector(reduceFontBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *enlargeFontBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    enlargeFontBtn.frame = CGRectMake(screenWidth/2+1, 50 , screenWidth/2, 30);
    [enlargeFontBtn setBackgroundColor:[UIColor whiteColor]];
    [enlargeFontBtn setTitle:@"+" forState:UIControlStateNormal];
    [enlargeFontBtn addTarget:self action:@selector(enlargeFontBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    
    
    UISlider *brightnessSlider = [[UISlider alloc]init];
    brightnessSlider.frame = CGRectMake(10, 20, screenWidth-20, 2);
    brightnessSlider.value = 0.6;
    brightnessSlider.minimumValue = 0.2;
    brightnessSlider.maximumValue = 1.0;
    [brightnessSlider addTarget:self action:@selector(changeScreenBrightness:) forControlEvents:UIControlEventValueChanged];
    
    UIButton *whiteBkgBtn = [self backgroundColorButtonWithColor:[UIColor whiteColor] andTag:0];
    whiteBkgBtn.frame = CGRectMake(15, 100, screenWidth/5, 30);
    [whiteBkgBtn addTarget:self action:@selector(setThemeColor:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *yellowBkgBtn = [self backgroundColorButtonWithColor:[UIColor colorWithRed:1.00 green:0.95 blue:0.80 alpha:1.0] andTag:1];
    yellowBkgBtn.frame = CGRectOffset(whiteBkgBtn.frame, screenWidth/5+12, 0);
    [yellowBkgBtn addTarget:self action:@selector(setThemeColor:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *grayBkgBtn = [self backgroundColorButtonWithColor:[UIColor colorWithRed:0.26 green:0.26 blue:0.26 alpha:1.0] andTag:2];
    grayBkgBtn.frame = CGRectOffset(yellowBkgBtn.frame, screenWidth/5+12, 0);
    [grayBkgBtn addTarget:self action:@selector(setThemeColor:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *blackBkgBtn = [self backgroundColorButtonWithColor:[UIColor blackColor] andTag:3];
    blackBkgBtn.frame = CGRectOffset(grayBkgBtn.frame, screenWidth/5+12, 0);
    [blackBkgBtn addTarget:self action:@selector(setThemeColor:) forControlEvents:UIControlEventTouchUpInside];
    
    [fontSizeChangeView addSubview:reduceFontBtn];
    [fontSizeChangeView addSubview:enlargeFontBtn];
    [fontSizeChangeView addSubview:brightnessSlider];
    [fontSizeChangeView addSubview:whiteBkgBtn];
    [fontSizeChangeView addSubview:yellowBkgBtn];
    [fontSizeChangeView addSubview:grayBkgBtn];
    [fontSizeChangeView addSubview:blackBkgBtn];
    [self.view addSubview:fontSizeChangeView];
    
}


- (UIButton *)backgroundColorButtonWithColor:(UIColor*)color andTag:(NSInteger)tag{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.layer.cornerRadius = 2;
    button.backgroundColor = color;
    button.tag = tag;
    return button;
}



- (void)loadBlogWebViewWithRatio:(CGFloat)ratio {

    NSString *cssTypeString = [NSString stringWithFormat:@"<html> \n"
                               "<style type='text/css'> \n"
                               "img { max-width: 100%%; width: auto; height: auto; }\n"
                               "h1 { font-size: %@px;} \n"
                               "h2 { font-size: %@px;} \n"
                               "p { font-size: %@px; } \n"
                               "a { color:#666666; text-decoration:none; border-bottom:1px dashed #808080} \n"
                               "table { max-width: 100%%; width: auto; } \n"
                               "html { width: 100%%; overflow: hidden; } \n"
                               "p.date { font-size: %@px; }"
                               "body { color:#888888 }</style>", @(23*ratio), @(18*ratio), @(15*ratio), @(12*ratio)];
    
    NSString *htmlData  = [NSString stringWithFormat:
                           @"<h1>%@</h1><p class='date'>%@ / %@</p> %@", itemTitle, self.feedTitle, self.dateString, feedItem.content.length > feedItem.summary.length ? self.contentString : self.summaryString];
    [self setThemeBackgroundColorWithTag:textBackgroundColorTag];
    [blogWebView loadHTMLString:[cssTypeString stringByAppendingString:htmlData] baseURL:nil];
    [blogWebView setOpaque:NO];
    blogWebView.delegate = self;
}

#pragma mark -
#pragma mark UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    DDLogVerbose(@"%@:%@", THIS_FILE, THIS_METHOD);
    if ([[[request URL]scheme]isEqual:@"http"] || [[[request URL]scheme]isEqual:@"https"]) {
        leftBtnItem.enabled = YES;
        UIButton *leftButton = (UIButton *)leftBtnItem.customView;
        FIIconLayer *layer = (FIIconLayer *)[leftButton.layer.sublayers lastObject];
        layer.iconColor = [UIColor blackColor];
        [toolbar setItems:@[fixedSpace, leftBtnItem, flexibleSpace, fontBtn, flexibleSpace, shareBtn, fixedSpace]];
    } else {
        leftBtnItem.enabled = NO;
        UIButton *leftButton = (UIButton *)leftBtnItem.customView;
        FIIconLayer *layer = (FIIconLayer *)[leftButton.layer.sublayers lastObject];
        layer.iconColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
        [toolbar setItems:@[fixedSpace, leftBtnItem, flexibleSpace, bookmarkBtn, flexibleSpace, fontBtn, flexibleSpace, shareBtn, fixedSpace]];
    }
    return YES;
}


- (void) webViewDidFinishLoad:(UIWebView *)webView {
    DDLogVerbose(@"%@:%@", THIS_FILE, THIS_METHOD);
    [self reloadWebViewWithFontSize:globalFontSize];
}

- (void)reloadWebViewWithFontSize:(NSInteger)fontSize {

    NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%ld%%'",
                          (long)fontSize];
    [self.blogWebView stringByEvaluatingJavaScriptFromString:jsString];
}

#pragma mark -
#pragma mark Button Action

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


#pragma mark - Toolbar items actions

- (void)backToPreviousPage {
    DDLogVerbose(@"%@:%@", THIS_FILE, THIS_METHOD);
    nPagesViewd -= 2;
    if ([blogWebView canGoBack]) {
        [blogWebView goBack];
    } else {
        [self loadBlogWebViewWithRatio:1.0f];
    }
}


- (void)addToBookMarks {
    
    if (!isBookmarked) {
        LZItem *item = [LZManagedObjectManager insertIntoItemDBWithItem:feedItem withContext:managedObjectContext];
        [LZManagedObjectManager insertIntoLikeDBWithItem:item andFeedTitle:feedTitle withContext:managedObjectContext];
        
        bookmarkBtn.image = [UIImage imageNamed:@"ic_star_y"];
        bookmarkBtn.tintColor = [UIColor colorWithRed:0.99 green:0.99 blue:0.38 alpha:1.0];
        isBookmarked = YES;

        // Show text Hud
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"已加喜欢";
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        
        [hud hide:YES afterDelay:1];
        
        
        NSLog(@"Bookmark!!!");
    } else {
        [self removeLZLikeItemAndLZItem];
        bookmarkBtn.image = [UIImage imageNamed:@"ic_star_w"];
        isBookmarked = NO;
        bookmarkBtn.tintColor = [UIColor blackColor];
        
        // Show text hud
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


- (void)removeLZLikeItemAndLZItem{

    LZLikeItem *likeItem = [LZManagedObjectManager getLikeItemByIdentifier:feedItem.identifier withContext:managedObjectContext];
    LZItem *item = [LZManagedObjectManager getItemByIdentifier:feedItem.identifier withContext:managedObjectContext];
    
    if (item==nil) {
        NSLog(@"Item is nil");
    }
    if (likeItem==nil) {
        NSLog(@"LikeItem is nil");
    }
    if (likeItem && item) {
        //[[NSNotificationCenter defaultCenter] postNotificationName:kModifyLZLikeItemArrayNotification object:self userInfo:@{@"identifier":item.identifier}];
        [managedObjectContext deleteObject:likeItem];
        [managedObjectContext deleteObject:item];
        [managedObjectContext save:nil];
        
    }

}


- (void)changeFontSize {
    
    [UIView animateWithDuration:0.2 animations:^{
        fontSizeChangeView.frame = CGRectMake(0, screenHeight-170, screenWidth, 170);
    }];

    isFontChangeViewDisplayed = YES;

}

- (void)shareBtnPressed {
    NSMutableArray *sharingItems = [[NSMutableArray alloc]init];
    NSString *text = [NSString stringWithFormat:@"%@ %@ via RSSReader", itemTitle, identifierString];
    [sharingItems addObject:text];

    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
    
}


- (void)setThemeColor:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeThemeColorNotification object:nil userInfo:@{@"themeColorTag":[NSNumber numberWithInteger:sender.tag]}];
    NSUInteger tag = sender.tag;
    [self setThemeBackgroundColorWithTag:tag];
}

- (void)setThemeBackgroundColorWithTag:(NSInteger)tag {
    textBackgroundColorTag = tag;
    switch (tag) {
        case 0:
            [blogWebView setBackgroundColor:[UIColor whiteColor]];
            
            //[toolbar setBarTintColor:[UIColor whiteColor]];
            [UIScreen mainScreen].brightness = 0.8;
            
            break;
        case 1:
            [blogWebView setBackgroundColor:[UIColor colorWithRed:1.00 green:0.95 blue:0.80 alpha:1.0]];
            //[toolbar setBarTintColor:[UIColor colorWithRed:1.00 green:0.95 blue:0.80 alpha:1.0]];
            [UIScreen mainScreen].brightness = 0.6;
            break;
            
        case 2:
            [blogWebView setBackgroundColor:[UIColor colorWithRed:0.26 green:0.26 blue:0.26 alpha:1.0]];
            //[toolbar setBarTintColor:[UIColor colorWithRed:0.26 green:0.26 blue:0.26 alpha:1.0]];
            [UIScreen mainScreen].brightness = 0.4;
            break;
            
        case 3:
            [blogWebView setBackgroundColor:[UIColor blackColor]];
            
            [UIScreen mainScreen].brightness = 0.2;
            //Change Toolbar tint color
            
            break;
        default:
            break;
    }

}

- (void) changeScreenBrightness:(UISlider *)sender {
    [[UIScreen mainScreen] setBrightness:sender.value];
}


#pragma mark -
#pragma mark Recognizer methods


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch locationInView:self.view].y < screenHeight -150 && isFontChangeViewDisplayed == YES) {
        //[fontSizeChangeView removeFromSuperview];
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

@end
