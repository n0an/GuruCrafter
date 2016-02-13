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

#import "ANMessageTableViewCell.h"
#import "ANMessage.h"

#import "UIImageView+AFNetworking.h"


@interface ANMessagesViewController ()

@property (strong, nonatomic) ANServerManager* serverManager;

@property (strong, nonatomic) NSMutableArray* messages;

@property (assign, nonatomic) BOOL loadingData;

@property (strong, nonatomic) NSString* sourceFullName;
@property (strong, nonatomic) NSURL* sourceImageURL;



@end

static NSInteger messagesInRequest = 20;


@implementation ANMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    NSLog(@"ANMessagesViewController, partnerUserID = %@", self.partnerUserID);
    
        if (self.partnerUser != nil) {
        self.sourceFullName = [NSString stringWithFormat:@"%@ %@", self.partnerUser.firstName, self.partnerUser.lastName];
        self.sourceImageURL = self.partnerUser.imageURL;
        
    } else if (self.partnerGroup != nil) {
        self.sourceFullName = [NSString stringWithFormat:@"%@ %@", self.partnerGroup.groupName];
        self.sourceImageURL = self.partnerGroup.imageURL;
    }
    
    
    self.serverManager = [ANServerManager sharedManager];
    
    self.navigationItem.title = self.sourceFullName;
    
    self.loadingData = YES;
    
    self.messages = [NSMutableArray array];
    
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
                  
//                  [self.tableView reloadData];
                  
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *messageSentIdentifier =        @"messageSentCell";
    static NSString *messageReceivedIdentifier =    @"messageReceivedCell";
    
    NSLog(@"self.messages = %@", self.messages);

    
    ANMessage* message = [self.messages objectAtIndex:indexPath.row];
    
    
    ANUser* currentUser = self.serverManager.currentUser;
    
    NSString* selfUserID = currentUser.userID;

    if ([message.authorID isEqualToString:selfUserID]) {
        /**
         *       THIS IS THE MESSAGE SENT BY US
         */
        
        ANMessageTableViewCell* messageSentCell = [tableView dequeueReusableCellWithIdentifier:messageSentIdentifier];
        
        if (!messageSentCell) {
            messageSentCell = [[ANMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:messageSentIdentifier];
        }
        
        messageSentCell.messageDateLabel.text = message.messageDate;
        messageSentCell.messageTextLabel.text = message.messageText;
        
        messageSentCell.messageAuthorFullNameLabel.text = [NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName];
        
        [messageSentCell.messageAuthorImageView setImageWithURL:currentUser.imageURL];
        
        return messageSentCell;
        
        
        
    } else if ([message.authorID isEqualToString:self.partnerUserID]) {
        /**
         *       THIS IS THE MESSAGE SENT BY PARTNER
        */
        
        ANMessageTableViewCell* messageReceivedCell = [tableView dequeueReusableCellWithIdentifier:messageReceivedIdentifier];
        
        if (!messageReceivedCell) {
            messageReceivedCell = [[ANMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:messageReceivedIdentifier];
        }
        
        messageReceivedCell.messageDateLabel.text = message.messageDate;
        messageReceivedCell.messageTextLabel.text = message.messageText;

        messageReceivedCell.messageAuthorFullNameLabel.text = self.sourceFullName;
        [messageReceivedCell.messageAuthorImageView setImageWithURL:self.sourceImageURL];
        
        
        return messageReceivedCell;

    }
    
    
    
    return nil;
    
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewAutomaticDimension;
    
}



- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewAutomaticDimension; // Auto Layout elements in the cell
    
}




@end
