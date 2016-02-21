//
//  ANPhoto.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 08/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANPhoto.h"

@implementation ANPhoto



- (id) initWithServerResponse:(NSDictionary*) responseObject {
    
    self = [super init];
    if (self) {
        
        self.width = [[responseObject objectForKey:@"width"] integerValue];
        self.height = [[responseObject objectForKey:@"height"] integerValue];

        self.photo_75 = [responseObject objectForKey:@"photo_75"];
        self.photo_130 = [responseObject objectForKey:@"photo_130"];
        self.photo_604 = [responseObject objectForKey:@"photo_604"];
        self.photo_807 = [responseObject objectForKey:@"photo_807"];
        self.photo_1280 = [responseObject objectForKey:@"photo_1280"];
        self.photo_2560 = [responseObject objectForKey:@"photo_2560"];
        
        if (self.photo_2560) {
            self.maxRes = self.photo_2560;
        } else if (self.photo_1280) {
            self.maxRes = self.photo_1280;
        } else if (self.photo_807) {
            self.maxRes = self.photo_807;
        } else if (self.photo_604) {
            self.maxRes = self.photo_604;
        } else if (self.photo_130) {
            self.maxRes = self.photo_130;
        } else {
            self.maxRes = self.photo_75;
        }
        
        
        self.text = [responseObject objectForKey:@"text"];
        
        self.likesCount = [[[responseObject objectForKey:@"likes"] objectForKey:@"count"] stringValue];
        
        self.isLikedByMyself = !([[[responseObject objectForKey:@"likes"] objectForKey:@"user_likes"] boolValue]);
        
        NSDateFormatter *dateWithFormat = [[NSDateFormatter alloc] init];
        [dateWithFormat setDateFormat:@"dd.MM.yyyy HH:mm"];
        
        NSTimeInterval Date = [[responseObject objectForKey:@"date"] intValue];
        NSDate *dateValue = [NSDate dateWithTimeIntervalSince1970:Date];
        
        self.date = [dateWithFormat stringFromDate:dateValue];
        
        
        
    }
    return self;
    
}





@end
