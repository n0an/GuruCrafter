//
//  ANVideoPlayerVC.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 03/03/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ANVideo;



@interface ANVideoPlayerVC : UIViewController

@property (strong, nonatomic) ANVideo* selectedVideo;



@property (weak, nonatomic) IBOutlet UITableView* tableView;


@end
