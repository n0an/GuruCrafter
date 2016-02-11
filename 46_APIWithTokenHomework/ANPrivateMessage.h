//
//  ANPrivateMessage.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 11/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANServerObject.h"

@interface ANPrivateMessage : ANServerObject

@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSDate *date;

@end
