//
//  ANVideoAlbum.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 22/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANVideoAlbum.h"

@implementation ANVideoAlbum

- (id) initWithServerResponse:(NSDictionary*) responseObject
{
    self = [super initWithServerResponse:responseObject];
    if (self) {
        
        self.albumSize = [[responseObject objectForKey:@"count"] stringValue];
        
        NSString* urlString = [responseObject objectForKey:@"photo_320"];
        
        if (urlString) {
            self.albumThumbImageURL = [NSURL URLWithString:urlString];
        }
        
        NSDateFormatter *dateWithFormat = [[NSDateFormatter alloc] init];
        [dateWithFormat setDateFormat:@"dd.MM.yyyy HH:mm"];
        
        NSTimeInterval rawDate = [[responseObject objectForKey:@"updated_time"] intValue];
        NSDate *dateValue = [NSDate dateWithTimeIntervalSince1970:rawDate];
        
        self.date = [dateWithFormat stringFromDate:dateValue];

    }
    return self;
}




@end
