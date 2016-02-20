//
//  ANUploadServer.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 20/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANUploadServer.h"

@implementation ANUploadServer

- (id) initWithServerResponse:(NSDictionary*) responseObject
{
    self = [super initWithServerResponse:responseObject];
    if (self) {
        
        self.albumID = [[responseObject objectForKey:@"album_id"] stringValue];
        self.uploadURL = [responseObject objectForKey:@"upload_url"];
        
        self.userID = [[responseObject objectForKey:@"user_id"] stringValue];
        
    }
    return self;
}



@end
