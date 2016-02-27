//
//  ANPostCommentsViewController.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 15/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ANPost;

@interface ANPostCommentsViewController : UIViewController


@property (weak, nonatomic) IBOutlet UITableView* tableView;

@property (weak, nonatomic) IBOutlet UIView* toolBarView;

@property (weak, nonatomic) IBOutlet UITextField* messageTextField;;
@property (weak, nonatomic) IBOutlet UIButton* sendButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint* toolbarViewToBottomConstraint;


- (IBAction)actionSendButtonPressed:(UIButton*)sender;
- (IBAction)actionMsgTxtFieldEditingChanged:(UITextField*)sender;




@property (strong, nonatomic) NSString* groupID;
@property (strong, nonatomic) NSString* postID;

@property (strong, nonatomic) ANPost* post;






@end
