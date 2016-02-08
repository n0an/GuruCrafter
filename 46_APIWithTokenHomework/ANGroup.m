//
//  ANGroup.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 08/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANGroup.h"

@implementation ANGroup

- (id) initWithServerResponse:(NSDictionary*) responseObject
{
    self = [super initWithServerResponse:responseObject];
    if (self) {
        
        self.groupName = [responseObject objectForKey:@"name"];
        self.screenName = [responseObject objectForKey:@"screen_name"];
        
        self.groupID = [[responseObject objectForKey:@"id"] stringValue];
        
        NSString* urlString = [responseObject objectForKey:@"photo_100"];
        
        if (urlString) {
            self.imageURL = [NSURL URLWithString:urlString];
        }
    }
    return self;
}



@end
