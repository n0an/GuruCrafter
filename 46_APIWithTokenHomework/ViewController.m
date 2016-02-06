//
//  ViewController.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 06/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ViewController.h"
#import "ANServerManager.h"
#import "ANUser.h"
#import "UIImageView+AFNetworking.h"


@interface ViewController ()

@property (strong, nonatomic) NSMutableArray* friendsArray;

@property (assign, nonatomic) BOOL firstTimeAppear;

@end

static NSInteger friendsInRequest = 20;


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.friendsArray = [NSMutableArray array];
    

    self.firstTimeAppear = YES;
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.firstTimeAppear) {
        
        self.firstTimeAppear = NO;
        
        [[ANServerManager sharedManager] authorizeUser:^(ANUser *user) {
            NSLog(@"AUTHORIZED!");
            NSLog(@"%@ %@", user.firstName, user.lastName);
        }];
    }
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
