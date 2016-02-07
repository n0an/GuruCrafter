//
//  ANPost.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 06/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANPost.h"

@implementation ANPost

- (id) initWithServerResponse:(NSDictionary*) responseObject
{
    self = [super initWithServerResponse:responseObject];
    if (self) {
        
        self.text = [responseObject objectForKey:@"text"];
        
        self.text = [self.text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
        
        
        self.comments = [[[responseObject objectForKey:@"comments"] objectForKey:@"count"] stringValue];
        self.likes = [[[responseObject objectForKey:@"likes"] objectForKey:@"count"] stringValue];
        
    }
    return self;
}


@end
