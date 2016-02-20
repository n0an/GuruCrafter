//
//  ANPhotoAlbum.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 20/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANPhotoAlbum.h"

@implementation ANPhotoAlbum

- (id) initWithServerResponse:(NSDictionary*) responseObject
{
    self = [super initWithServerResponse:responseObject];
    if (self) {
        
        self.albumID = [[responseObject objectForKey:@"id"] stringValue];
        self.albumTitle = [responseObject objectForKey:@"title"];
        
        self.albumDescription = [responseObject objectForKey:@"description"];
        
        self.albumSize = [[responseObject objectForKey:@"size"] stringValue];
        
        NSString* urlString = [responseObject objectForKey:@"thumb_src"];
        
        if (urlString) {
            self.albumThumbImageURL = [NSURL URLWithString:urlString];
        }
    }
    return self;
}



@end
