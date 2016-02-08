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

@interface ANPost : ANServerObject

@property (strong, nonatomic) NSString* text;

@property (strong, nonatomic) NSString* date;
@property (strong, nonatomic) NSURL* postImageURL;
@property (assign, nonatomic) NSInteger heightImage;
@property (assign, nonatomic) NSInteger widthImage;

@property (strong, nonatomic) NSString* comments;
@property (strong, nonatomic) NSString* likes;

@property (assign, nonatomic) NSInteger sizeText;
@property (strong, nonatomic) UIImage* postImage;

@property (strong, nonatomic) NSString* authorID;
@property (strong, nonatomic) ANUser* author;


@end
