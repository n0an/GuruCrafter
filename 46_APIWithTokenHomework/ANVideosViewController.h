//
//  ANVideosViewController.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 23/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ANVideoAlbum;

@interface ANVideosViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView* tableView;

@property (strong, nonatomic) ANVideoAlbum* videoAlbum;

@end
