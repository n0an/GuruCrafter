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
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

#pragma mark - Actions


- (IBAction)actionSendPressed:(UIButton*)sender {
    NSLog(@"actionSendPressed");
    NSLog(@"message = %@", self.messageTextField.text);
    
    
    [self.delegate sendButtonPressedWithMessage:self.messageTextField.text];
    
}







#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    NSLog(@"textFieldDidBeginEditing");
    NSLog(@"textField.text = %@", textField.text);

    
    self.sendMessageButton.enabled = YES;
    
}

@end
