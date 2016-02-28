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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"start"]) {
        
        
    }
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
