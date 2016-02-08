//
//  ANGroup.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 08/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANServerObject.h"

@interface ANGroup : ANServerObject

@property (strong, nonatomic) NSString* groupName;
@property (strong, nonatomic) NSString* screenName;
@property (strong, nonatomic) NSURL* imageURL;

@property (strong, nonatomic) NSString* groupID;


@end
