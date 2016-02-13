//
//  ANMessagesViewController.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 13/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANMessagesViewController.h"
#import "ANUser.h"
#import "ANGroup.h"
#import "ANServerManager.h"

@interface ANMessagesViewController ()

@property (strong, nonatomic) ANServerManager* serverManager;

@property (strong, nonatomic) NSMutableArray* messages;

@property (assign, nonatomic) BOOL loadingData;

@end

static NSInteger messagesInRequest = 20;


@implementation ANMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    NSLog(@"ANMessagesViewController, partnerUserID = %@", self.partnerUserID);
    
    self.serverManager = [ANServerManager sharedManager];

    self.navigationController.title = @"Messages";
    
    self.loadingData = YES;
    
    [self getMessagesFromServer];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - API


- (void) getMessagesFromServer {
    
    
    [[ANServerManager sharedManager] getMessagesForUser:self.partnerUserID
             withOffset:[self.messages count]
                  count:messagesInRequest
              onSuccess:^(NSArray *messages) {
                  [self.messages addObjectsFromArray:messages];
                  
                  NSMutableArray* newPaths = [NSMutableArray array];
                  
                  for (int i = (int)[self.messages count] - (int)[messages count]; i < [self.messages count]; i++) {
                      [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                  }
                  
                  [self.tableView beginUpdates];
                  [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationFade];
                  [self.tableView endUpdates];
                  
                  
                  self.loadingData = NO;
                  
                  
              }
              onFailure:^(NSError *error, NSInteger statusCode) {
                  NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
              }];

    
}



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messages count];
}








@end
