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

@property (strong, nonatomic) NSString* src_big;
@property (strong, nonatomic) NSString* src_small;
@property (strong, nonatomic) NSString* src_xbig;
@property (strong, nonatomic) NSString* src_xxbig;
@property (strong, nonatomic) NSString* src_xxxbig;



@end
