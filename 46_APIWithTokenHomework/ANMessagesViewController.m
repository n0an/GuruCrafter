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

#import "ANNewMessageCell.h"


@interface ANMessagesViewController () <UIScrollViewDelegate, ANNewMessageDelegate>

@property (strong, nonatomic) ANServerManager* serverManager;

@property (strong, nonatomic) NSMutableArray* messages;

@property (assign, nonatomic) BOOL loadingData;

@property (strong, nonatomic) NSString* sourceFullName;
@property (strong, nonatomic) NSURL* sourceImageURL;

@property (assign, nonatomic) NSInteger sectionsCount;




@end

static NSInteger messagesInRequest = 20;


@implementation ANMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    NSLog(@"ANMessagesViewController, partnerUserID = %@", self.partnerUserID);
  
    self.sectionsCount = 1;
    
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
    
    
    UIRefreshControl* refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshMessagesHistory) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Actions

- (IBAction)actionComposePressed:(UIBarButtonItem*)sender {
    NSLog(@"actionComposePressed");
    
    if (self.sectionsCount == 1) {
        self.sectionsCount = 2;
    } else {
        self.sectionsCount = 1;
    }
    
//    self.sectionsCount = 2;
    
    [self.tableView reloadData];
    
    
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


- (void) refreshMessagesHistory {
    
    self.loadingData = YES;
    
    [[ANServerManager sharedManager] getMessagesForUser:self.partnerUserID
         withOffset:0
              count:MAX(messagesInRequest, [self.messages count])
          onSuccess:^(NSArray *messages) {
              
              [self.messages removeAllObjects];
              [self.messages addObjectsFromArray:messages];
              
              [self.tableView reloadData];
              [self.refreshControl endRefreshing];
              self.loadingData = NO;
              
          } onFailure:^(NSError *error, NSInteger statusCode) {
              
          }];

}


- (void) sendMessage:(NSString*) message {
    
    [[ANServerManager sharedManager] sendMessage:message
              toUser:self.partnerUserID
           onSuccess:^(id result) {
               
               NSLog(@"MESSAGE SENT");
               
               self.sectionsCount = 1;
               
               [self refreshMessagesHistory];
           }
     
           onFailure:^(NSError *error, NSInteger statusCode) {
               
           }];
    
    
    
}




#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.sectionsCount == 2) {
        if (section == 0) {
            return 1;
        } else if (section == 1) {
            return [self.messages count];
        }
    }
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ((self.sectionsCount == 2) && (indexPath.section == 0)) {
        static NSString* newMessageIdentifier = @"newMessageCell";
        
        ANNewMessageCell* newMessageCell = [tableView dequeueReusableCellWithIdentifier:newMessageIdentifier];
        
        if (!newMessageCell) {
            newMessageCell = [[ANNewMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:newMessageIdentifier];
        }
        
        newMessageCell.delegate = self;
        
        return newMessageCell;
        
    }
    
    
    
    if ((self.sectionsCount == 1) || ((self.sectionsCount == 2) && (indexPath.section == 1))) {
        static NSString *messageSentIdentifier =        @"messageSentCell";
        static NSString *messageReceivedIdentifier =    @"messageReceivedCell";
        
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



#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
        if (!self.loadingData)
        {
            self.loadingData = YES;
            [self getMessagesFromServer];
        }
    }
}

#pragma mark - +++ ANNewMessageDelegate +++
- (void) sendButtonPressedWithMessage:(NSString*) message {
    NSLog(@"sendButtonPressedWithMessage");
    NSLog(@"received message = %@",message);
    
    [self sendMessage:message];
    


}



@end
