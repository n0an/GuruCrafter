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

@property (strong, nonatomic) ANUser* currentUser;

//@property (strong, nonatomic) NSURL* photoSelfURL;

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



- (void) getMessagesForUser:(NSString*) userID
                 withOffset:(NSInteger) offset
                      count:(NSInteger) count
                  onSuccess:(void(^)(NSArray* messages)) success
                  onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;


- (void) sendMessage:(NSString*) text
              toUser:(NSString*) userID
           onSuccess:(void(^)(id result)) success
           onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;




- (void) getCommentsForGroup:(NSString*) groupID
                      PostID:(NSString*) postID
                  withOffset:(NSInteger) offset
                       count:(NSInteger) count
                   onSuccess:(void(^)(NSArray* comments)) success
                   onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;


- (void) addComment:(NSString*) text
        onGroupWall:(NSString*) groupID
            forPost:(NSString*) postID
          onSuccess:(void(^)(id result)) success
          onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;


- (void) addLikeForItemType:(NSString*) itemType
                 forOwnerID:(NSString*) ownerID
                  forItemID:(NSString*) itemID
                  onSuccess:(void(^)(id result)) success
                  onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;


@end
