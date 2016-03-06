//
//  ANJSQMessagesVC.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 04/03/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSQMessagesViewController/JSQMessages.h>
#import <JSQMessagesViewController/JSQMessagesBubbleImageFactory.h>

@class ANMessage;
@class ANUser;

@interface ANJSQMessagesVC : JSQMessagesViewController <UIActionSheetDelegate>


@property (strong, nonatomic) NSURL *avatarIncoming;
@property (strong, nonatomic) NSURL *avatarOutgoing;


@end
