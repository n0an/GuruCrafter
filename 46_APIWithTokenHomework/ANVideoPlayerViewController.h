//
//  ANVideoPlayerViewController.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 23/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ANVideo;

@interface ANVideoPlayerViewController : UIViewController

@property (strong, nonatomic) ANVideo* selectedVideo;

@property (weak, nonatomic) IBOutlet UIWebView* playerWebView;
@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UILabel* descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel* likesCountLabel;
@property (weak, nonatomic) IBOutlet UILabel* viewsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel* dateLabel;





@end
