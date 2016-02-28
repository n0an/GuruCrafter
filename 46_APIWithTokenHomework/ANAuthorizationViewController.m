//
//  ANAuthorizationViewController.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 28/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANAuthorizationViewController.h"
#import <SWRevealViewController.h>
#import "ANServerManager.h"
#import "ANUser.h"


@interface ANAuthorizationViewController ()

@property (assign, nonatomic) BOOL firstTimeApper;


@end

@implementation ANAuthorizationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.firstTimeApper = YES;
    

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];

    if (self.firstTimeApper) {
        self.firstTimeApper = NO;
        
        [[ANServerManager sharedManager] authorizeUser:^(ANUser *user) {
            
            NSLog(@"AUTHORIZED!");
            NSLog(@"%@ %@", user.firstName, user.lastName);
            
            ANServerManager* serverManager = [ANServerManager sharedManager];
            serverManager.currentUser = user;
            
            SWRevealViewController *revealVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
            
            [self presentViewController:revealVC animated:YES completion:nil];
            
        }];
    }
    
}




@end
