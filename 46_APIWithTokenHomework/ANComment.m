//
//  ANComment.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 15/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANComment.h"

@implementation ANComment

- (id) initWithServerResponse:(NSDictionary*) responseObject {
    
    self = [super initWithServerResponse:responseObject];
    
    if (self) {
        self.text = [self refineAuthor:self.text];
    }
    

    return self;
}


- (NSString*) refineAuthor:(NSString*) commentText {
    
    //[id134187741|Elow]
    NSString* string = commentText;
    if ([commentText hasPrefix:@"[id"]) {
        
        NSRange range2 = [string rangeOfString:@"],"];
        NSRange range1 = [string rangeOfString:@"|"];
        
        NSRange range = NSMakeRange(range1.location + 1, range2.location - range1.location - 1);
        
        NSString* rawAuthor = [string substringWithRange:range];
        
        NSString* finedAuthor = [rawAuthor stringByAppendingString:@","];
        
        NSString* otherText = [string substringFromIndex:range2.location + range2.length];
        
        string = [finedAuthor stringByAppendingString:otherText];
        
    }
    return string;
}


@end
