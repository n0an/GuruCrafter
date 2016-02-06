//
//  ANServerManager.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 06/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ANUser;

@interface ANServerManager : NSObject

@property (strong, nonatomic, readonly) ANUser* currentUser;

+ (ANServerManager*) sharedManager;


- (void) authorizeUser:(void(^)(ANUser* user)) completion;


- (void) getUser:(NSString*) userID
       onSuccess:(void(^)(ANUser* user)) success
       onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void) getFriendsWithOffset:(NSInteger) offset
                        count:(NSInteger) count
                    onSuccess:(void(^)(NSArray* friends)) success
                    onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;


- (void) getGroupWall:(NSString*) groupID
           withOffset:(NSInteger) offset
                count:(NSInteger) count
            onSuccess:(void(^)(NSArray* posts)) success
            onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;



- (void) postText:(NSString*) text
      onGroupWall:(NSString*) groupID
        onSuccess:(void(^)(id result)) success
        onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

@end
