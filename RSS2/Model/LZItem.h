//
//  LZItem.h
//  RSS2
//
//  Created by luzheng1208 on 15/2/15.
//  Copyright (c) 2015年 luzheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LZItem : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * coverImageURLString;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * update;
@property (nonatomic, retain) NSNumber * isBookmarked;

@end
