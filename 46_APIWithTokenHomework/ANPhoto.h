//
//  ANPhoto.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 08/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANServerObject.h"

//typedef enum {
//
//    ANPhotoResolution_First = 0,
//    ANPhotoResolution75 = 0,
//    ANPhotoResolution130 = 1,
//    ANPhotoResolution604 = 2,
//    ANPhotoResolution807 = 3,
//    ANPhotoResolution1280 = 4,
//    ANPhotoResolution2560 = 5,
//    ANPhotoResolution_Last = 5
//
//} ANPhotoResolution;


typedef enum {
    
    ANPhotoResolution_First = 0,
    ANPhotoResolution75 = ANPhotoResolution_First,
    ANPhotoResolution130,
    ANPhotoResolution604,
    ANPhotoResolution807,
    ANPhotoResolution1280,
    ANPhotoResolution2560,
    ANPhotoResolution_Last = ANPhotoResolution2560
    
} ANPhotoResolution;


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

@property (strong, nonatomic) NSArray* keysResArray;

@property (strong, nonatomic) NSDictionary* resolutionsDictionary;


@property (strong, nonatomic) NSString* text;
@property (strong, nonatomic) NSString* date;
@property (strong, nonatomic) NSString* likesCount;
@property (assign, nonatomic) BOOL isLikedByMyself;




@end
