//
//  ANMessage.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 13/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANServerObject.h"


@interface ANMessage : ANServerObject


@property (strong, nonatomic) NSString* userId;

@property (strong, nonatomic) NSString* body;

@property (strong, nonatomic) NSDate* date;


@end
