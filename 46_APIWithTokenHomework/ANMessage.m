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
        
        NSTimeInterval Date = [[responseObject objectForKey:@"date"] intValue];
        NSDate *dateValue = [NSDate dateWithTimeIntervalSince1970:Date];
        self.messageDate = [dateWithFormat stringFromDate:dateValue];
        
        self.authorID = [[responseObject objectForKey:@"from_id"] stringValue];
    
        self.messageText = [responseObject objectForKey:@"body"];
    
    
    
    }
    return self;
}



@end
