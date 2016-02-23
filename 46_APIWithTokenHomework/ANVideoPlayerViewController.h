//
//  ANVideoPlayerViewController.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 23/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

@interface ANVideoPlayerViewController : AVPlayerViewController

@property (strong, nonatomic) NSURL* videoURL;


@end
