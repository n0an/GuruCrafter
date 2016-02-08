//
//  ANPost.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 06/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANServerObject.h"
#import <UIKit/UIKit.h>

@class ANUser;
@class ANGroup;

@interface ANPost : ANServerObject

@property (strong, nonatomic) NSString* text;

@property (strong, nonatomic) NSString* date;

@property (strong, nonatomic) NSURL* postMainImageURL;
@property (assign, nonatomic) NSInteger heightImage;
@property (assign, nonatomic) NSInteger widthImage;

@property (strong, nonatomic) NSString* comments;
@property (strong, nonatomic) NSString* likes;

@property (strong, nonatomic) NSString* authorID;
@property (strong, nonatomic) ANUser* author;
@property (strong, nonatomic) ANGroup* fromGroup;


@property (strong, nonatomic) NSArray* attachmentsArray;


@end
