//
//  ANPhoto.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 08/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANServerObject.h"

@interface ANPhoto : ANServerObject

@property (assign, nonatomic) NSInteger width;
@property (assign, nonatomic) NSInteger height;

@property (strong, nonatomic) NSString* photo_75;
@property (strong, nonatomic) NSString* photo_130;
@property (strong, nonatomic) NSString* photo_604;
@property (strong, nonatomic) NSString* photo_807;
@property (strong, nonatomic) NSString* photo_1280;
@property (strong, nonatomic) NSString* photo_2560;

@property (strong, nonatomic) NSString* maxRes;


@property (strong, nonatomic) NSString* text;
@property (strong, nonatomic) NSString* date;
@property (strong, nonatomic) NSString* likesCount;
@property (assign, nonatomic) BOOL isLikedByMyself;




@end
