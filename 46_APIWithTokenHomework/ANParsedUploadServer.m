//
//  ANParsedUploadServer.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 22/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANParsedUploadServer.h"

@implementation ANParsedUploadServer

- (id) initWithServerResponse:(NSDictionary*) responseObject
{
    self = [super initWithServerResponse:responseObject];
    if (self) {
        
        self.server = [[responseObject objectForKey:@"server"] stringValue];
        
        self.photosList = [responseObject objectForKey:@"photos_list"];
        
        self.albumID = [[responseObject objectForKey:@"aid"] stringValue];
        
        self.groupID = [[responseObject objectForKey:@"gid"] stringValue];
        
        self.hashCode = [responseObject objectForKey:@"hash"];
        
        
        
    }
    return self;
}

@end