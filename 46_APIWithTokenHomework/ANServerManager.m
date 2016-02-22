//
//  ANServerManager.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 06/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANServerManager.h"
#import "AFNetworking.h"
#import "ANUser.h"
#import "ANLoginViewController.h"
#import "ANAccessToken.h"

#import "ANPost.h"
#import "ANGroup.h"

#import "ANMessage.h"
#import "ANComment.h"
#import "ANPhotoAlbum.h"

#import "ANUploadServer.h"
#import "ANPhoto.h"
#import "ANParsedUploadServer.h"

@interface ANServerManager ()

@property (strong, nonatomic) AFHTTPRequestOperationManager* requestOperationManager;

@property (strong, nonatomic) ANAccessToken* accessToken;

@end


@implementation ANServerManager


+ (ANServerManager*) sharedManager {
    
    static ANServerManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ANServerManager alloc] init];
    });
    
    return manager;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSURL* url = [NSURL URLWithString:@"https://api.vk.com/method/"];
        
        self.requestOperationManager = [[AFHTTPRequestOperationManager manager] initWithBaseURL:url];
    }
    return self;
}


#pragma mark - User methods

- (void) authorizeUser:(void(^)(ANUser* user)) completion {
    
    ANLoginViewController* vc = [[ANLoginViewController alloc] initWithCompletionBlock:^(ANAccessToken *token) {
        self.accessToken = token;
        
        if (token) {
            
            [self getUser:self.accessToken.userID
                onSuccess:^(ANUser *user) {
                    if (completion) {
                        completion(user);
                    }
                    
                } onFailure:^(NSError *error, NSInteger statusCode) {
                    
                    if (completion) {
                        completion(nil);
                    }
                    
                }];
            
        } else if (completion) {
            completion(nil);
            
        }
        
        
    }];
    
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    UIViewController* mainVC = [[UIApplication sharedApplication] keyWindow].rootViewController;
    
    //    UIViewController* mainVC2 = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
    
    [mainVC presentViewController:nav
                         animated:YES
                       completion:nil];
    
}




- (void) getUser:(NSString*) userID
       onSuccess:(void(^)(ANUser* user)) success
       onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    
    
    NSDictionary* params =
    [NSDictionary dictionaryWithObjectsAndKeys:
     userID,        @"user_ids",
     @"photo_100",  @"fields",
     @"nom",        @"name_case",
     @"5.45",       @"v", nil];
    
    [self.requestOperationManager
     GET:@"users.get"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
//         NSLog(@"JSON: %@", responseObject);
         
         NSArray* dictsArray = [responseObject objectForKey:@"response"];
         
         if ([dictsArray count] > 0) {
             ANUser* user = [[ANUser alloc] initWithServerResponse:[dictsArray firstObject]];
             if (success) {
                 success(user);
             }
             
         } else {
             if (failure) {
                 failure(nil, operation.response.statusCode);
             }
         }
         
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
             
         }
     }];
    

}


- (void) getFriendsWithOffset:(NSInteger) offset
                        count:(NSInteger) count
                    onSuccess:(void(^)(NSArray* friends)) success
                    onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    NSDictionary* params =
    [NSDictionary dictionaryWithObjectsAndKeys:
     @"21743772",   @"user_id",
     @"name",       @"order",
     @(count),      @"count",
     @(offset),     @"offset",
     @"photo_50",   @"fields",
     @"nom",        @"name_case",
     @"5.45",       @"v",
     nil];
    
    [self.requestOperationManager
     GET:@"friends.get"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         NSLog(@"JSON: %@", responseObject);
         
         NSArray* dictsArray = [responseObject objectForKey:@"response"];
         
         NSMutableArray* objectsArray = [NSMutableArray array];
         
         for (NSDictionary* dict in dictsArray) {
             ANUser* user = [[ANUser alloc] initWithServerResponse:dict];
             [objectsArray addObject:user];
         }
         
         if (success) {
             success(objectsArray);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
             
         }
     }];
    
}


#pragma mark - Group wall methods

- (void) getGroupWall:(NSString*) groupID
           withOffset:(NSInteger) offset
                count:(NSInteger) count
            onSuccess:(void(^)(NSArray* posts)) success
            onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    if (![groupID hasPrefix:@"-"]) {
        groupID = [@"-" stringByAppendingString:groupID];
    }
    
    
    NSDictionary* params =
    [NSDictionary dictionaryWithObjectsAndKeys:
     groupID,                   @"owner_id",
     @(offset),                 @"offset",
     @(count),                  @"count",
     @"all",                    @"filter",
     @"1",                      @"extended",
     @"5.21",                   @"v",
     self.accessToken.token,    @"access_token",
     nil];
    
    
    
    [self.requestOperationManager
     GET:@"wall.get"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         NSLog(@"getGroupWall JSON: %@", responseObject);
         
         NSDictionary* response = [responseObject objectForKey:@"response"];
         
         NSArray* profiles = [response objectForKey:@"profiles"];
         NSArray* wall = [response objectForKey:@"items"];
         NSArray* groups = [response objectForKey:@"groups"];

         
         // *** WE HAVE ONLY ONE GROUP - iOSDevCourse group. Getting it to object
         
         ANGroup* group = [[ANGroup alloc] initWithServerResponse:[groups objectAtIndex:0]];

         
         
         // *** CREATING AUTHORS PROFILES ARRAY
         NSMutableArray* authorsArray = [NSMutableArray array];
         
         for (NSDictionary* dict in profiles) {
             ANUser* author = [[ANUser alloc] initWithServerResponse:dict];
             
             [authorsArray addObject:author];
         }
         
         
         // *** CREATING POSTS ARRAY, AND GETTING AUTHOR FOR EACH POST

         
         NSMutableArray* postsArray = [NSMutableArray array];
         
         for (NSDictionary* dict in wall) {
             ANPost* post = [[ANPost alloc] initWithServerResponse:dict];
             [postsArray addObject:post];
             
             // **** ITERATING THROUGH ARRAY OF AUTHORS - LOOKING FOR AUTHOR FOR THIS POST
             
             for (ANUser* author in authorsArray) {
                 
                 if ([post.authorID hasPrefix:@"-"]) {
                     post.fromGroup = group;
                     continue;
                 }
                 
                 if ([author.userID isEqualToString:post.authorID]) {
                     post.author = author;
                 }
             }
             
         }
         
         
         if (success) {
             success(postsArray);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
             
         }
     }];
    
    
}



- (void) refreshPostID:(NSString*) postID
            forOwnerID:(NSString*) ownerID
            onSuccess:(void(^)(ANPost* post)) success
            onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    if (![ownerID hasPrefix:@"-"]) {
        ownerID = [@"-" stringByAppendingString:ownerID];
    }
    
    NSString* cumulativeID = [NSString stringWithFormat:@"%@_%@",ownerID,postID];
    
    
    NSDictionary* params =
    [NSDictionary dictionaryWithObjectsAndKeys:
     cumulativeID,              @"posts",
     @"1",                      @"extended",
     self.accessToken.token,    @"access_token",
     @"5.45",                   @"v",
     nil];
    
    
    
    [self.requestOperationManager
     GET:@"wall.getById"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
        
         NSLog(@"wall.getById JSON: %@", responseObject);
         
         NSDictionary* response = [responseObject objectForKey:@"response"];
         
         NSArray* profiles = [response objectForKey:@"profiles"];
         NSArray* wall = [response objectForKey:@"items"];
         NSArray* groups = [response objectForKey:@"groups"];
         
         ANGroup* group = [[ANGroup alloc] initWithServerResponse:[groups objectAtIndex:0]];
         ANUser* author = [[ANUser alloc] initWithServerResponse:[profiles objectAtIndex:0]];
         ANPost* post = [[ANPost alloc] initWithServerResponse:[wall objectAtIndex:0]];
         
         if ([post.authorID hasPrefix:@"-"]) {
             post.fromGroup = group;
         } else {
             post.author = author;
         }

         
         if (success) {
             success(post);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
             
         }
     }];
    
    
}



- (void) postText:(NSString*) text
      onGroupWall:(NSString*) groupID
        onSuccess:(void(^)(id result)) success
        onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    
    if (![groupID hasPrefix:@"-"]) {
        groupID = [@"-" stringByAppendingString:groupID];
    }
    
    
    NSDictionary* params =
    [NSDictionary dictionaryWithObjectsAndKeys:
     groupID,                   @"owner_id",
     text,                      @"message",
     self.accessToken.token,    @"access_token",
     @"5.45",                   @"v",
     nil];
    
    
    [self.requestOperationManager
     POST:@"wall.post"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         NSLog(@"JSON: %@", responseObject);
         
         
         if (success) {
             success(responseObject);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
             
         }
     }];
    
    
}


#pragma mark - Private messages methods

- (void) getMessagesForUser:(NSString*) userID
           withOffset:(NSInteger) offset
                count:(NSInteger) count
            onSuccess:(void(^)(NSArray* messages)) success
            onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    
    NSDictionary* params =
    [NSDictionary dictionaryWithObjectsAndKeys:
     self.accessToken.token,    @"access_token",
     userID,                    @"user_id",
     @(count),                  @"count",
     @(offset),                 @"offset",
     @"5.45",                   @"v", nil];
    
    
    
    [self.requestOperationManager
     GET:@"messages.getHistory"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         NSLog(@"messages.getHistory JSON: %@", responseObject);
         
         NSDictionary* response = [responseObject objectForKey:@"response"];

         NSArray* itemsArray = [response objectForKey:@"items"];
         
         NSMutableArray* messagesArray = [NSMutableArray array];

         for (NSDictionary* dict in itemsArray) {
             ANMessage* message = [[ANMessage alloc] initWithServerResponse:dict];
             [messagesArray addObject:message];
         }
         
         if (success) {
             success(messagesArray);
         }
         
         
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
             
         }
     }];
    
}


- (void) sendMessage:(NSString*) text
      toUser:(NSString*) userID
        onSuccess:(void(^)(id result)) success
        onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    
    NSDictionary* params =
    [NSDictionary dictionaryWithObjectsAndKeys:
     userID,                    @"user_id",
     text,                      @"message",
     self.accessToken.token,    @"access_token",
     @"5.45",                   @"v",
     nil];
    
    
    [self.requestOperationManager
     POST:@"messages.send"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         NSLog(@"messages.send JSON: %@", responseObject);
         
         
         if (success) {
             success(responseObject);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
             
         }
     }];
    
    
}



#pragma mark - Comments methods

- (void) getCommentsForGroup:(NSString*) groupID
                      PostID:(NSString*) postID
           withOffset:(NSInteger) offset
                count:(NSInteger) count
            onSuccess:(void(^)(NSArray* comments)) success
            onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    if (![groupID hasPrefix:@"-"]) {
        groupID = [@"-" stringByAppendingString:groupID];
    }
    
    
    NSDictionary* params =
    [NSDictionary dictionaryWithObjectsAndKeys:
     groupID,                   @"owner_id",
     postID,                    @"post_id",
     @(count),                  @"count",
     @(offset),                 @"offset",
     @"1",                      @"need_likes",
     @"1",                      @"extended",
     @"desc",                   @"sort",
     self.accessToken.token,    @"access_token",
     @"5.45",                   @"v", nil];
    
    
    
    [self.requestOperationManager
     GET:@"wall.getComments"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         NSLog(@"wall.getComments JSON: %@", responseObject);
         
         NSDictionary* response = [responseObject objectForKey:@"response"];

         NSArray* profiles = [response objectForKey:@"profiles"];
         NSArray* items = [response objectForKey:@"items"];
         NSArray* groups = [response objectForKey:@"groups"];

         // *** WE HAVE ONLY ONE GROUP - iOSDevCourse group. Getting it to object
         
         ANGroup* group;
         if ([groups count] > 0) {
             group = [[ANGroup alloc] initWithServerResponse:[groups objectAtIndex:0]];
         }
         
         
         
         // *** CREATING AUTHORS PROFILES ARRAY
         NSMutableArray* authorsArray = [NSMutableArray array];
         
         for (NSDictionary* dict in profiles) {
             ANUser* author = [[ANUser alloc] initWithServerResponse:dict];
             
             [authorsArray addObject:author];
         }
         
         
         // *** CREATING COMMENTS ARRAY, AND GETTING AUTHOR FOR EACH COMMENT
         
         NSMutableArray* comments = [NSMutableArray array];
         
         for (NSDictionary* dict in items) {
             ANComment* comment = [[ANComment alloc] initWithServerResponse:dict];
             [comments addObject:comment];
             
             // **** ITERATING THROUGH ARRAY OF AUTHORS - LOOKING FOR AUTHOR FOR THIS COMMENT
             
             for (ANUser* author in authorsArray) {
                 
                 if ([comment.authorID hasPrefix:@"-"]) {
                     comment.fromGroup = group;
                     continue;
                 }
                 
                 if ([author.userID isEqualToString:comment.authorID]) {
                     comment.author = author;
                 }
             }
             
         }
         
         
         if (success) {
             success(comments);
         }

         

     }
     
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
             
         }
     }];
    
    
}



- (void) addComment:(NSString*) text
         onGroupWall:(NSString*) groupID
             forPost:(NSString*) postID
        onSuccess:(void(^)(id result)) success
        onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    
    if (![groupID hasPrefix:@"-"]) {
        groupID = [@"-" stringByAppendingString:groupID];
    }
    
    
    NSDictionary* params =
    [NSDictionary dictionaryWithObjectsAndKeys:
     groupID,                   @"owner_id",
     postID,                    @"post_id",
     text,                      @"text",
     self.accessToken.token,    @"access_token",
     @"5.45",                   @"v",
     nil];
    
    
    [self.requestOperationManager
     POST:@"wall.addComment"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         NSLog(@"wall.addComment JSON: %@", responseObject);
         
         
         if (success) {
             success(responseObject);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
             
         }
     }];
    
    
}

#pragma mark - Likes add/delete methods

- (void) addLikeForItemType:(NSString*) itemType
                 forOwnerID:(NSString*) ownerID
                  forItemID:(NSString*) itemID
          onSuccess:(void(^)(NSDictionary* result)) success
          onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    
    if (![ownerID hasPrefix:@"-"]) {
        ownerID = [@"-" stringByAppendingString:ownerID];
    }
    
    NSDictionary* params =
    [NSDictionary dictionaryWithObjectsAndKeys:
     itemType,                  @"type",
     itemID,                    @"item_id",
     self.accessToken.token,    @"access_token",
     ownerID,                   @"owner_id",
     @"5.45",                   @"v",
     nil];
    
    
    [self.requestOperationManager
     POST:@"likes.add"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         NSLog(@"likes.add JSON: %@", responseObject);
         
         NSDictionary* result = [responseObject objectForKey:@"response"];
         
         if (success) {
             success(result);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
             
         }
     }];
    
    
}



- (void) deleteLikeForItemType:(NSString*) itemType
                    forOwnerID:(NSString*) ownerID
                     forItemID:(NSString*) itemID
                     onSuccess:(void(^)(NSDictionary* result)) success
                     onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    
    if (![ownerID hasPrefix:@"-"]) {
        ownerID = [@"-" stringByAppendingString:ownerID];
    }
    
    NSDictionary* params =
    [NSDictionary dictionaryWithObjectsAndKeys:
     itemType,                  @"type",
     itemID,                    @"item_id",
     self.accessToken.token,    @"access_token",
     ownerID,                   @"owner_id",
     @"5.45",                   @"v",
     nil];
    
    
    [self.requestOperationManager
     POST:@"likes.delete"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         NSLog(@"likes.delete JSON: %@", responseObject);
         
         NSDictionary* result = [responseObject objectForKey:@"response"];
         
         if (success) {
             success(result);
         }
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
             
         }
     }];
    
    
}


- (void) getIsLikeForItemType:(NSString*) itemType
                   forOwnerID:(NSString*) ownerID
                    forUserID:(NSString*) userID
                    forItemID:(NSString*) itemID
                    onSuccess:(void(^)(BOOL isLiked)) success
                    onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    
    if (![ownerID hasPrefix:@"-"]) {
        ownerID = [@"-" stringByAppendingString:ownerID];
    }
    
    NSDictionary* params =
    [NSDictionary dictionaryWithObjectsAndKeys:
     userID,                    @"user_id",
     itemType,                  @"type",
     ownerID,                   @"owner_id",
     itemID,                    @"item_id",
     @"5.45",                   @"v",
     self.accessToken.token,    @"access_token",
     nil];
    
    
    [self.requestOperationManager
     POST:@"likes.isLiked"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         NSLog(@"likes.isLiked JSON: %@", responseObject);
         
         NSDictionary* response = [responseObject objectForKey:@"response"];
         
         BOOL isLiked = [[response objectForKey:@"liked"] boolValue];
         
         if (success) {
             success(isLiked);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
             
         }
     }];
    
    
}

#pragma mark - Photos uploading methods

- (void) getGroupAlbums:(NSString*) groupID
             withOffset:(NSInteger) offset
                  count:(NSInteger) count
              onSuccess:(void(^)(NSArray* photoAlbums)) success
              onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    if (![groupID hasPrefix:@"-"]) {
        groupID = [@"-" stringByAppendingString:groupID];
    }
    
    
    NSDictionary* params =
    [NSDictionary dictionaryWithObjectsAndKeys:
     groupID,                   @"owner_id",
     @(offset),                 @"offset",
     @(count),                  @"count",
     @"1",                      @"need_covers",
     @"5.45",                   @"v",
     self.accessToken.token,    @"access_token",
     nil];
    
    
    [self.requestOperationManager
     GET:@"photos.getAlbums"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         NSLog(@"photos.getAlbums JSON: %@", responseObject);
         
         NSDictionary* response = [responseObject objectForKey:@"response"];
         
         NSArray* items = [response objectForKey:@"items"];
         
         NSMutableArray* albumsArray = [NSMutableArray array];
         
         for (NSDictionary* dict in items) {
             ANPhotoAlbum* photoAlbum = [[ANPhotoAlbum alloc] initWithServerResponse:dict];
             [albumsArray addObject:photoAlbum];
             
         }
         
         
         if (success) {
             success(albumsArray);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
             
         }
     }];
    
    
}


- (void) getPhotosForGroup:(NSString*) groupID
                forAlbumID:(NSString*) albumID
                withOffset:(NSInteger) offset
                     count:(NSInteger) count
                 onSuccess:(void(^)(NSArray* photos)) success
                 onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    if (![groupID hasPrefix:@"-"]) {
        groupID = [@"-" stringByAppendingString:groupID];
    }
    
    
    NSDictionary* params =
    [NSDictionary dictionaryWithObjectsAndKeys:
     groupID,                   @"owner_id",
     albumID,                   @"album_id",
     @(offset),                 @"offset",
     @(count),                  @"count",
     @"1",                      @"rev",
     @"1",                      @"extended",
     @"5.45",                   @"v",
     self.accessToken.token,    @"access_token",
     nil];
    
    
    [self.requestOperationManager
     GET:@"photos.get"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         NSLog(@"photos.get JSON: %@", responseObject);
         
         NSDictionary* response = [responseObject objectForKey:@"response"];
         
         NSArray* items = [response objectForKey:@"items"];
         
         NSMutableArray* photosArray = [NSMutableArray array];
         
         for (NSDictionary* dict in items) {
             ANPhoto* photo = [[ANPhoto alloc] initWithServerResponse:dict];
             [photosArray addObject:photo];
             
         }
         
         
         if (success) {
             success(photosArray);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
             
         }
     }];
    
    
}



- (void) getUploadServerForGroupID:(NSString*) groupID
                   forPhotoAlbumID:(NSString*) albumID
                         onSuccess:(void(^)(ANUploadServer* uploadServer)) success
                         onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
 
    NSDictionary* params =
    [NSDictionary dictionaryWithObjectsAndKeys:
     groupID,                   @"group_id",
     albumID,                   @"album_id",
     self.accessToken.token,    @"access_token",
     @"5.45",                   @"v",
     nil];
    
    
    [self.requestOperationManager
     GET:@"photos.getUploadServer"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         NSLog(@"photos.getUploadServer JSON: %@", responseObject);
         
         NSDictionary* response = [responseObject objectForKey:@"response"];
         
         ANUploadServer* uploadServer = [[ANUploadServer alloc] initWithServerResponse:response];
         
         if (success) {
             success(uploadServer);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
             
         }
     }];
    
    
}


- (void) getUploadJSONStringForServerURL:(NSString*) uploadServerURL
        fileToUpload:(NSData*) fileData
          onSuccess:(void(^)(ANParsedUploadServer* parsedUploadServer)) success
          onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {

    
    AFHTTPRequestOperationManager* requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    
    [requestManager
     POST:uploadServerURL parameters:nil
     constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
         [formData appendPartWithFileData:fileData name:@"file1" fileName:@"file1.jpg" mimeType:@"image/jpeg"];
     }
     
     success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
         NSLog(@"POST SAVE JSON: %@", responseObject);
         
         ANParsedUploadServer* parsedUploadServer = [[ANParsedUploadServer alloc] initWithServerResponse:responseObject];
         
         if (success) {
             success(parsedUploadServer);
         }

     }
     
     failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
         failure(error, operation.response.statusCode);
     }];
    
}



- (void) uploadPhotosToGroupWithServer:(ANParsedUploadServer*) parsedUploadServer
                   onSuccess:(void(^)(id result)) success
                   onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    NSDictionary* params =
    [NSDictionary dictionaryWithObjectsAndKeys:
     parsedUploadServer.groupID,    @"group_id",
     parsedUploadServer.albumID,    @"album_id",
     parsedUploadServer.server,     @"server",
     parsedUploadServer.photosList, @"photos_list",
     parsedUploadServer.hashCode,   @"hash",
     self.accessToken.token,        @"access_token",
     @"5.45",                       @"v",
     nil];
    
    
    [self.requestOperationManager
     POST:@"photos.save"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         NSLog(@"photos.save JSON: %@", responseObject);
         
         
         if (success) {
             success(responseObject);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
             
         }
     }];
    
    
}




@end
