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

        self.src_small = [responseObject objectForKey:@"src_small"];
        self.src_big = [responseObject objectForKey:@"src_big"];
        self.src_xbig = [responseObject objectForKey:@"src_xbig"];
        self.src_xxbig = [responseObject objectForKey:@"src_xxbig"];
        self.src_xxxbig = [responseObject objectForKey:@"src_xxxbig"];
    }
    return self;
    
}

@end
