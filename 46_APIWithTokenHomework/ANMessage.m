//
//  ANMessage.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 13/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANMessage.h"

@implementation ANMessage


- (id) initWithServerResponse:(NSDictionary*) responseObject
{
    self = [super initWithServerResponse:responseObject];
    if (self) {
        
        NSDateFormatter *dateWithFormat = [[NSDateFormatter alloc] init];
        [dateWithFormat setDateFormat:@"dd.MM.yyyy HH:mm"];
        
        NSTimeInterval rawDate = [[responseObject objectForKey:@"date"] doubleValue];
        NSDate *dateValue = [NSDate dateWithTimeIntervalSince1970:rawDate];
//        self.date = [dateWithFormat stringFromDate:dateValue];
        self.date = dateValue;
        
        self.userId = [[responseObject objectForKey:@"from_id"] stringValue];
    
        self.body = [responseObject objectForKey:@"body"];
    
    
    
    }
    return self;
}



@end
