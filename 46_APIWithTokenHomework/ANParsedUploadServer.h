//
//  ANParsedUploadServer.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 22/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANServerObject.h"

@interface ANParsedUploadServer : ANServerObject

@property (strong, nonatomic) NSString* server;

@property (strong, nonatomic) NSString* photosList;

@property (strong, nonatomic) NSString* albumID;

@property (strong, nonatomic) NSString* groupID;

@property (strong, nonatomic) NSString* hashCode;



@end
