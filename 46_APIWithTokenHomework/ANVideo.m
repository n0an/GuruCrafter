//
//  ANVideo.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 22/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANVideo.h"

@implementation ANVideo

- (id) initWithServerResponse:(NSDictionary*) responseObject {
    
    self = [super init];
    if (self) {
        
        
        self.videoID = [[responseObject objectForKey:@"id"] stringValue];
        self.title = [responseObject objectForKey:@"title"];
        
        self.duration = [[responseObject objectForKey:@"duration"] stringValue];

        self.videoDescription = [responseObject objectForKey:@"description"];

        NSDateFormatter *dateWithFormat = [[NSDateFormatter alloc] init];
        [dateWithFormat setDateFormat:@"dd.MM.yyyy HH:mm"];
        
        NSTimeInterval rawDate = [[responseObject objectForKey:@"date"] intValue];
        NSDate *dateValue = [NSDate dateWithTimeIntervalSince1970:rawDate];
        
        self.date = [dateWithFormat stringFromDate:dateValue];

        self.videoPlayerURLString = [responseObject objectForKey:@"player"];
        
        self.likesCount = [[[responseObject objectForKey:@"likes"] objectForKey:@"count"] stringValue];
        
        self.isLikedByMyself = !([[[responseObject objectForKey:@"likes"] objectForKey:@"user_likes"] boolValue]);

        
        self.views = [[responseObject objectForKey:@"views"] stringValue];
        self.comments = [[responseObject objectForKey:@"comments"] stringValue];

        NSString* urlString = [responseObject objectForKey:@"photo_320"];
        
        if (urlString) {
            self.videoThumbImageURL = [NSURL URLWithString:urlString];
        }

    
    }
    return self;
    
}



@end















