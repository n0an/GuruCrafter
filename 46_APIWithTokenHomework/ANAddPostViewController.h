//
//  ANAddPostViewController.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 08/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ANAddPostDelegate;


@interface ANAddPostViewController : UIViewController


@property (weak, nonatomic) IBOutlet UITextView *postMessageTextView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;

@property (strong, nonatomic) id <ANAddPostDelegate> delegate;

- (IBAction)actionSend:(UIBarButtonItem *)sender;
- (IBAction)actionCancel:(UIBarButtonItem *)sender;


@end

@protocol ANAddPostDelegate <NSObject>

@required

- (void) postDidSend;

@end