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
 
        self.videoDescription = [responseObject objectForKey:@"description"];

        NSInteger rawDuration = [[responseObject objectForKey:@"duration"] integerValue];
        self.duration = [self processDuration:rawDuration];
        
        NSTimeInterval rawDate = [[responseObject objectForKey:@"date"] intValue];
        self.date = [self processDate:rawDate];

        self.videoPlayerURLString = [responseObject objectForKey:@"player"];
        
        self.likesCount = [[[responseObject objectForKey:@"likes"] objectForKey:@"count"] stringValue];
        
        self.isLikedByMyself = !([[[responseObject objectForKey:@"likes"] objectForKey:@"user_likes"] boolValue]);

        
        self.views = [[responseObject objectForKey:@"views"] stringValue];
        self.comments = [[responseObject objectForKey:@"comments"] stringValue];

        NSString* urlString = [responseObject objectForKey:@"photo_130"];
        
        if (urlString) {
            self.videoThumbImageURL = [NSURL URLWithString:urlString];
        }

    
    }
    return self;
    
}


- (NSString*) processDate:(NSTimeInterval) rawDate {
    
    NSDateFormatter *dateWithFormat = [[NSDateFormatter alloc] init];
    [dateWithFormat setDateFormat:@"dd.MM.yyyy HH:mm"];
    
    NSDate *dateValue = [NSDate dateWithTimeIntervalSince1970:rawDate];
    
    return [dateWithFormat stringFromDate:dateValue];
    
}

- (NSString*) processDuration:(NSInteger) rawTime {
    
    NSUInteger h = rawTime / 3600;
    NSUInteger m = (rawTime / 60) % 60;
    NSUInteger s = rawTime % 60;
    
    NSString* processedTime;
    if (rawTime < 3600) {
        processedTime = [NSString stringWithFormat:@"%02lu:%02lu",(unsigned long)m, (unsigned long)s];
    } else {
        processedTime = [NSString stringWithFormat:@"%lu:%02lu:%02lu", (unsigned long)h, (unsigned long)m, (unsigned long)s];;
    }

    return processedTime;
}



@end















