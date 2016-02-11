//
//  ANPrivateMessage.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 11/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANPrivateMessage.h"

@implementation ANPrivateMessage


- (id)initWithServerResponse:(NSDictionary *)responseObject {
    
    self = [super initWithServerResponse:responseObject];
    if (self) {
        
        NSTimeInterval unixtime = [[responseObject objectForKey:@"date"] doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixtime];
        
        NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"dd.MM.yyyy hh:mm"];
        
        //self.date = [formatter stringFromDate:date];
        self.date = date;
        
        self.body = [responseObject objectForKey:@"body"];
        
        self.userId = [responseObject objectForKey:@"user_id"];
        
    }
    return self;
}



@end
