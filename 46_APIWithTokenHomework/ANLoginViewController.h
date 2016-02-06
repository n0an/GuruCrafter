//
//  ANLoginViewController.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 06/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ANAccessToken;

typedef void(^ANLoginCompletionBlock)(ANAccessToken* token);

@interface ANLoginViewController : UIViewController

- (id) initWithCompletionBlock:(ANLoginCompletionBlock) completionBlock;


@end
