//
//  ANChatViewController.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 10/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ANChatViewController : UIViewController

@property (strong, nonatomic) NSString* userID;


@property (weak, nonatomic) IBOutlet UILabel* testMessageLabel;


@end
