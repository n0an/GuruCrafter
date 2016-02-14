//
//  ANNewMessageCell.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 14/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ANNewMessageDelegate;

@interface ANNewMessageCell : UITableViewCell <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField* messageTextField;
@property (weak, nonatomic) IBOutlet UIButton* sendMessageButton;

@property (strong, nonatomic) id <ANNewMessageDelegate> delegate;


- (IBAction)actionSendPressed:(UIButton*)sender;

- (IBAction)actionTextChanged:(UITextField*)sender;


@end

@protocol ANNewMessageDelegate <NSObject>

- (void) sendButtonPressedWithMessage:(NSString*) message;

@end