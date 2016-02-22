//
//  ANVideo.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 22/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANServerObject.h"

@interface ANVideo : ANServerObject


@property (strong, nonatomic) NSString* videoID;

@property (strong, nonatomic) NSString* title;

@property (strong, nonatomic) NSString* duration;

@property (strong, nonatomic) NSString* videoDescription;

@property (strong, nonatomic) NSString* date;

@property (strong, nonatomic) NSString* videoPlayerURLString;

@property (strong, nonatomic) NSString* views;
@property (strong, nonatomic) NSString* comments;
@property (strong, nonatomic) NSString* likesCount;
@property (assign, nonatomic) BOOL isLikedByMyself;



@property (strong, nonatomic) NSURL* videoThumbImageURL;


@end
