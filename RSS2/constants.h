//
//  constants.h
//  RSSReader
//
//  Created by luzheng1208 on 15/2/6.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

// Notification
#define kAddFeedNotification                            @"kAddFeedNotification"
#define kModifyLZLikeItemArrayNotification              @"kModifyLZLikeItemArrayNotification"
#define kChangeThemeColorNotification                   @"ChangeThemeColorNotification"
#define kChangeMainViewLayoutNotification               @"ChangeMainViewLayout"

// Global varibles key
#define kGlobalFontSize                                 @"kGlobalFontSize"
#define kTextBackgroundColorTag                         @"kTextBackgroundColorTag"
#define kMainViewLayout                                 @"kMainViewLayout"
#define kTableViewCellIdentifier                        @"com.luzheng.sampleCell"
#define kLastOpenFeedIdentifier                         @"kLastOpenFeedIdentifier"

// DB Constants
#define kLZLikeItemEntityString                         @"LZLikeItem"
#define kLZItemEntityString                             @"LZItem"
#define kLZFeedInfoEntityString                         @"LZFeedInfo"
#define kLZSubsFeedEntityString                         @"LZSubscribeFeed"


// Macro
#define OBJ_IS_NIL(s) (s==nil || [s isKindOfClass:[NSNull class]])
#define kScreenWidth        [UIScreen mainScreen].bounds.size.width
#define kScreenHeight       [UIScreen mainScreen].bounds.size.height

// Feedly search API
#define kFeedlySearchAPI                                @"http://cloud.feedly.com/v3/search/feeds?query="


// Table view cell identifier
#define kItemFullTableViewCellIdentifier                @"kItemFullTableViewCellIdentifier"


// Enum
typedef enum { LZLayoutList, LZLayoutView, LZLayoutFull } LZLayoutType;
