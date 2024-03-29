//
//  ANPost.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 06/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANPost.h"
#import "ANPhoto.h"

@implementation ANPost

- (id) initWithServerResponse:(NSDictionary*) responseObject
{
    self = [super initWithServerResponse:responseObject];
    if (self) {
        
        self.postID = [[responseObject objectForKey:@"id"] stringValue];
        
        self.text = [self stringByStrippingHTML:[responseObject objectForKey:@"text"]];
        
        self.comments = [[[responseObject objectForKey:@"comments"] objectForKey:@"count"] stringValue];
        self.likes = [[[responseObject objectForKey:@"likes"] objectForKey:@"count"] stringValue];
                
        self.isLikedByMyself = !([[[responseObject objectForKey:@"likes"] objectForKey:@"can_like"] boolValue]);
        
        NSDateFormatter *dateWithFormat = [[NSDateFormatter alloc] init];
        [dateWithFormat setDateFormat:@"dd MMM yyyy | HH:mm"];
        
        NSTimeInterval rawDate = [[responseObject objectForKey:@"date"] intValue];
        NSDate *dateValue = [NSDate dateWithTimeIntervalSince1970:rawDate];
        self.date = [dateWithFormat stringFromDate:dateValue];
        
        self.authorID = [[responseObject objectForKey:@"from_id"] stringValue];
        
        
        
        // *** ATTACHMENTS ARRAY
        NSArray* attachments = [responseObject objectForKey:@"attachments"];
        
        NSMutableArray* attachmentsArray = [NSMutableArray array];
        
        for (NSDictionary* dict in attachments) {
            
            if ([[dict objectForKey:@"type"] isEqualToString:@"photo"]) {
                ANPhoto* photo = [[ANPhoto alloc] initWithServerResponse:[dict objectForKey:@"photo"]];
                [attachmentsArray addObject:photo];
            }
            
        }
        
                
        self.attachmentsArray = attachmentsArray;
        
        
        
        
    }
    return self;
}


- (NSString *) stringByStrippingHTML:(NSString *)string {
    
    NSRange r;
    while ((r = [string rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {
        
        string = [string stringByReplacingCharactersInRange:r withString:@""];
    }
    
    return string;
}


@end
