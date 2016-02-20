//
//  ANUploadServer.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 20/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANServerObject.h"

@interface ANUploadServer : ANServerObject


@property (strong, nonatomic) NSString* uploadURL;

@property (strong, nonatomic) NSString* albumID;

@property (strong, nonatomic) NSString* userID;


@end
