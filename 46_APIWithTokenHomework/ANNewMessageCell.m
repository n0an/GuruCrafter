//
//  ANNewMessageCell.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 14/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANNewMessageCell.h"

@implementation ANNewMessageCell

- (void)awakeFromNib {

    
    if ([self.messageTextField.text length] == 0) {
        self.sendMessageButton.enabled = NO;
    }
    
    self.sendMessageButton.layer.cornerRadius = 10;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

#pragma mark - Helper Methods

- (void) sendMessage {
    [self.delegate sendButtonPressedWithMessage:self.messageTextField.text];
    
    self.messageTextField.text = @"";
    
    self.sendMessageButton.enabled = NO;
}

#pragma mark - Actions


- (IBAction)actionSendPressed:(UIButton*)sender {
    
    [self sendMessage];
    
}

- (IBAction)actionTextChanged:(UITextField*)sender {
    
    if ([self.messageTextField.text length] > 0) {
        self.sendMessageButton.enabled = YES;
    } else {
        self.sendMessageButton.enabled = NO;
    }
}






#pragma mark - UITextFieldDelegate


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([self.messageTextField.text length] > 0) {
        [self sendMessage];
        [textField resignFirstResponder];

    }
    

    return YES;
    
}



@end
