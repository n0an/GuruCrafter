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

@end

@implementation ANAddPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self.postMessageTextView.text length] == 0) {
        self.sendButton.enabled = NO;
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.postMessageTextView.layer.cornerRadius = 10;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



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
