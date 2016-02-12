//
//  ANChatViewController.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 10/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSQMessagesViewController/JSQMessages.h>
#import <JSQMessagesViewController/JSQMessagesBubbleImageFactory.h>

@interface ANChatViewController : JSQMessagesViewController <UIActionSheetDelegate>

@property (strong, nonatomic) NSURL *photoSelfURL;
@property (strong, nonatomic) NSURL *photoPartnerURL;

- (IBAction)actionCancel:(UIBarButtonItem*)sender;


@end
