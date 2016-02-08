//
//  ANAddPostViewController.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 08/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ANAddPostViewController : UIViewController


@property (weak, nonatomic) IBOutlet UITextView *postMessageTextView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;


- (IBAction)actionSend:(UIBarButtonItem *)sender;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionCancel;

@end
