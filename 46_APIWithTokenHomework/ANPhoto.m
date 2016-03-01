//
//  ANPhoto.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 08/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANPhoto.h"

NSString* kPhoto_75 = @"photo_75";
NSString* kPhoto_130 = @"photo_130";
NSString* kPhoto_604 = @"photo_604";
NSString* kPhoto_807 = @"photo_807";
NSString* kPhoto_1208 = @"photo_1208";
NSString* kPhoto_2560 = @"photo_2560";






@implementation ANPhoto



- (id) initWithServerResponse:(NSDictionary*) responseObject {
    
    self = [super init];
    if (self) {
        
        
        self.keysResArray = @[kPhoto_75, kPhoto_130, kPhoto_604, kPhoto_807, kPhoto_1208, kPhoto_2560];
        
        self.width = [[responseObject objectForKey:@"width"] integerValue];
        self.height = [[responseObject objectForKey:@"height"] integerValue];

        self.photo_75 = [responseObject objectForKey:@"photo_75"];
        self.photo_130 = [responseObject objectForKey:@"photo_130"];
        self.photo_604 = [responseObject objectForKey:@"photo_604"];
        self.photo_807 = [responseObject objectForKey:@"photo_807"];
        self.photo_1280 = [responseObject objectForKey:@"photo_1280"];
        self.photo_2560 = [responseObject objectForKey:@"photo_2560"];
        
        
        self.resolutionsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                      self.photo_75, kPhoto_75,
                                      self.photo_130, kPhoto_130,
                                      self.photo_604, kPhoto_604,
                                      self.photo_807, kPhoto_807,
                                      self.photo_1280, kPhoto_1208,
                                      self.photo_2560, kPhoto_2560,
                                      nil];
        
        
        
        
        
        for (ANPhotoResolution i = ANPhotoResolution_Last; i >= ANPhotoResolution_First; i--) {
            
            NSString* keyRes = [self.keysResArray objectAtIndex:i];
            
            NSString* currentRes = [self.resolutionsDictionary objectForKey:keyRes];
            
            if (currentRes) {
                self.maxRes = currentRes;
                break;
            }
            
        }
        
    
        
        self.text = [responseObject objectForKey:@"text"];
        
        self.likesCount = [[[responseObject objectForKey:@"likes"] objectForKey:@"count"] stringValue];
        
        self.isLikedByMyself = !([[[responseObject objectForKey:@"likes"] objectForKey:@"user_likes"] boolValue]);
        
        NSDateFormatter *dateWithFormat = [[NSDateFormatter alloc] init];
        [dateWithFormat setDateFormat:@"dd.MM.yyyy HH:mm"];
        
        NSTimeInterval rawDate = [[responseObject objectForKey:@"date"] intValue];
        NSDate *dateValue = [NSDate dateWithTimeIntervalSince1970:rawDate];
        
        self.date = [dateWithFormat stringFromDate:dateValue];
        
        
        
    }
    return self;
    
}





@end
