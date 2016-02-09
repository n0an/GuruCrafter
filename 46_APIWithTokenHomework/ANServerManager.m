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
     @"5.44",       @"v", nil];
    
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
     @"nom",        @"name_case", nil];
    
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
     groupID,       @"owner_id",
     @(count),      @"count",
     @(offset),     @"offset",
     @"all",        @"filter",
     @"1",          @"extended",
     @"5.44",       @"v", nil];
    
    
    
    [self.requestOperationManager
     GET:@"wall.get"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         NSLog(@"JSON: %@", responseObject);
         
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


@end
