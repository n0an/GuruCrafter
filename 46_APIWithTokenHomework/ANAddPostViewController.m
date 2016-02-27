//
//  ANAddPostViewController.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 08/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANAddPostViewController.h"
#import "ANServerManager.h"

@interface ANAddPostViewController () <UITextViewDelegate>

@property (strong, nonatomic) UIToolbar *toolbar;

@property (strong, nonatomic) UITextView *textViewComment;
@property (strong, nonatomic) UIBarButtonItem *senderButton;

@end


@implementation ANAddPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self.postMessageTextView.text length] == 0) {
        self.sendButton.enabled = NO;
    }
    
/********
 * self.automaticallyAdjustsScrollViewInsets = NO;
 * !!!REMOVES VERTICAL INDENT FROM TOP OF TEXTVIEW TO THE FIRST TEXT LINE IN TEXTVIEW !!!
 *******/
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.postMessageTextView.layer.cornerRadius = 10;
    
    [self.postMessageTextView becomeFirstResponder];
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]
             addObserver:self
             selector:@selector(keyboardWillShow:)
             name:UIKeyboardWillShowNotification
             object:nil];
    
    [[NSNotificationCenter defaultCenter]
             addObserver:self
             selector:@selector(keyboardWillHide:)
             name:UIKeyboardWillHideNotification
             object:nil];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Notifications actions

- (void) keyboardWillShow:(NSNotification*) notification {
    
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGSize keyboardSize = keyboardRect.size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);

    [UIView animateWithDuration:0.3f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
            
                         self.textViewToBottomConstraint.constant = keyboardRect.size.height + 20;
                         
                         [self.view layoutIfNeeded];

                     } completion:nil];
    

    self.postMessageTextView.contentInset = contentInsets;
    self.postMessageTextView.scrollIndicatorInsets = contentInsets;
    
}

- (void) keyboardWillHide:(NSNotification*) notification {
    
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGSize keyboardSize = keyboardRect.size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);
    
    [UIView animateWithDuration:0.3f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         self.textViewToBottomConstraint.constant = 20;
                         
                         [self.view layoutIfNeeded];
                         
                     } completion:nil];
    
    
    self.postMessageTextView.contentInset = contentInsets;
    self.postMessageTextView.scrollIndicatorInsets = contentInsets;
    
}


#pragma mark - Helper methods



#pragma mark - API

- (void) postOnWallMessage:(NSString*) message {
    
    [[ANServerManager sharedManager]
     postText:message
     onGroupWall:@"58860049"
     onSuccess:^(id result) {
         
         [self.delegate postDidSend];
         
         [self.navigationController popViewControllerAnimated:YES];

     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         
     }];
    
}


#pragma mark - Actions


- (IBAction)actionSend:(UIBarButtonItem *)sender {
    
    [self postOnWallMessage:self.postMessageTextView.text];
    
    
}

- (IBAction)actionCancel:(UIBarButtonItem *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];

}



#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    
    if ([self.postMessageTextView.text length] > 0) {
        
        self.sendButton.enabled = YES;
    } else {
        self.sendButton.enabled = NO;
    }
    
}





@end
