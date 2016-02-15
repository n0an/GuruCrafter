//
//  ANPostCommentsViewController.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 15/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ANPost;

@interface ANPostCommentsViewController : UITableViewController

@property (strong, nonatomic) NSString* groupID;
@property (strong, nonatomic) NSString* postID;

@property (strong, nonatomic) ANPost* post;

@end
