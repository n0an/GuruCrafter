//
//  ANJSQMessagesVC.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 04/03/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANJSQMessagesVC.h"
#import "ANUser.h"
#import "ANMessage.h"

#import "ANServerManager.h"

#import "JSQMessagesCollectionView.h"
#import <CCBottomRefreshControl/UIScrollView+BottomRefreshControl.h>


@interface ANJSQMessagesVC ()

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@property (strong, nonatomic) NSMutableArray* messages;

@property (assign, nonatomic) BOOL loadingData;
@property (assign, nonatomic) BOOL firstFetch;

@property (strong, nonatomic) NSString* sourceFullName;
@property (strong, nonatomic) NSURL* sourceImageURL;

@property (strong, nonatomic) UIImage *imageAvatarIncoming;
@property (strong, nonatomic) UIImage *imageAvatarOutgoing;

@property (strong, nonatomic) UIRefreshControl* topRefreshControl;
@property (strong, nonatomic) UIRefreshControl* bottomRefreshControl;

@property (strong, nonatomic) NSOperation *currentOperation;
@property (strong, nonatomic) NSOperationQueue *queue;


@end

static NSInteger messagesInRequest = 20;



@implementation ANJSQMessagesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    UIRefreshControl* bottomRefresh = [[UIRefreshControl alloc] init];
    bottomRefresh.triggerVerticalOffset = 100.;
    [bottomRefresh addTarget:self action:@selector(refreshMessagesHistory) forControlEvents:UIControlEventValueChanged];
    
    self.collectionView.bottomRefreshControl = bottomRefresh;
    self.bottomRefreshControl = bottomRefresh;
    
    
    UIRefreshControl* topRefresh = [[UIRefreshControl alloc] init];
    [topRefresh addTarget:self action:@selector(topRefreshAction:) forControlEvents:UIControlEventValueChanged];
    
    [self.collectionView addSubview:topRefresh];
    
    self.topRefreshControl = topRefresh;
    
    
    self.imageAvatarOutgoing = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.avatarOutgoing]];
    self.imageAvatarIncoming = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.avatarIncoming]];
    
    self.loadingData = YES;
    self.firstFetch = YES;
    self.messages = [NSMutableArray array];
    [self getHistoryMessagesBackgroundFromServer:messagesInRequest offset:0];



    self.navigationItem.title = self.senderDisplayName;
    
    
    
    JSQMessagesBubbleImageFactory *bubbleFactory= [[JSQMessagesBubbleImageFactory alloc] init];
    
    self.outgoingBubbleImageData=[bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.incomingBubbleImageData=[bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    self.collectionView.collectionViewLayout.springinessEnabled = YES;
    
}




#pragma mark - Actions

- (void) topRefreshAction:(UIRefreshControl*) refreshControl {
    
    [self getHistoryMessagesBackgroundFromServer:messagesInRequest offset:[self.messages count]];
    
}



#pragma mark - API


- (void)getHistoryMessagesBackgroundFromServer:(NSInteger)count offset:(NSInteger)offset {
    
    self.queue = [[NSOperationQueue alloc] init];
    
    __weak NSOperation *weakCurrentOperation = self.currentOperation;
    
    __weak ANJSQMessagesVC* weakSelf = self;
    
    self.currentOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        if (![weakCurrentOperation isCancelled]) {
            
            [weakSelf getHistoryMessagesFromServer:count offset:offset];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf.collectionView reloadData];
            
            self.currentOperation = nil;
        });
        
    }];
    
    [self.queue addOperation:self.currentOperation];
}


- (void)getHistoryMessagesFromServer:(NSInteger)count offset:(NSInteger)offset {
    
    [[ANServerManager sharedManager] getMessagesForUser:self.senderId
         senderName:self.senderDisplayName
         withOffset:[self.messages count]
              count:messagesInRequest
          onSuccess:^(NSArray *messages) {
              
              [self.messages addObjectsFromArray:messages];
              
              NSSortDescriptor *date = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
              
              [self.messages sortUsingDescriptors:[NSArray arrayWithObject:date]];
              
              [self.collectionView reloadData];
              
              if (self.firstFetch) {
                  [self scrollToBottomAnimated:YES];
                  self.firstFetch = NO;
              }
              
              
              self.loadingData = NO;
              
              if (self.topRefreshControl.isRefreshing) {
                  [self.topRefreshControl endRefreshing];
              }
              
          }
          onFailure:^(NSError *error, NSInteger statusCode) {
              NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
              
              
          }];
    

}




- (void) refreshMessagesHistory {
    
    if (self.loadingData == NO) {
        self.loadingData = YES;
        
        
        [[ANServerManager sharedManager] getMessagesForUser:self.senderId
             senderName:self.senderDisplayName
             withOffset:0
                  count:MAX(messagesInRequest, [self.messages count])
              onSuccess:^(NSArray *messages) {
                  
                  if ([messages count] > 0) {
                      [self.messages removeAllObjects];
                      [self.messages addObjectsFromArray:messages];
                      
                      NSSortDescriptor* dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
                      [self.messages sortUsingDescriptors:@[dateDescriptor]];
                      
                      [self.collectionView reloadData];
                      
                  }
                  [self.bottomRefreshControl endRefreshing];

                  self.loadingData = NO;
                  
              }
              onFailure:^(NSError *error, NSInteger statusCode) {
                  NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
                  [self.bottomRefreshControl endRefreshing];

              }];
  
        
    }
    
    
}


- (void) sendMessage:(NSString*) message {
    
    [[ANServerManager sharedManager] sendMessage:message
                  toUser:self.senderId
               onSuccess:^(id result) {
                   
                   NSLog(@"MESSAGE SENT");
                   
                   [self finishSendingMessageAnimated:YES];
                   
                   [self refreshMessagesHistory];
               }

               onFailure:^(NSError *error, NSInteger statusCode) {
                   
               }];
    
    
}


#pragma mark - JSQMessagesVC methods

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date {
    

    [self sendMessage:text];
    
}



- (void)didPressAccessoryButton:(UIButton *)sender {
    
    NSLog(@"didPressAccessoryButton");
    
    
}




#pragma mark - JSQMessages Data Source methods

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    //Return the actual message at each indexpath.row
    return [self.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if (![self incoming:message]) {
        
        return self.outgoingBubbleImageData;
        
    } else {
        
        return self.incomingBubbleImageData;
    }
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
                    avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    UIImage *image = nil;
    
    if (![self incoming:message]) {
        
        image = self.imageAvatarIncoming;
        
    } else {
        
        image = self.imageAvatarOutgoing;
    }
    
    JSQMessagesAvatarImage *avatar = [JSQMessagesAvatarImageFactory avatarImageWithImage:image diameter:20];
    return avatar;
}


- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
    //cell.cellBottomLabel.text = [dateFormatter stringFromDate:message.date];
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:[dateFormatter stringFromDate:message.date]];
    return attributedString;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage *message = self.messages[indexPath.item];
    
    if ([self incoming:message]) {
        return nil;
    }
    if (indexPath.item - 1 > 0) {
        
        JSQMessage *previous = self.messages[indexPath.item - 1];
        if ([previous.senderId isEqualToString:message.senderId]) {
            
            return nil;
        }
    }
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.messages count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if (!message.isMediaMessage) {
        
        if (![self incoming:message]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleThick | NSUnderlinePatternSolid)};
    }
    
    return cell;
    
}

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    //if (indexPath.item % 3 == 0) {
    //return kJSQMessagesCollectionViewCellLabelHeightDefault;
    //}
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    //iOS7-style sender name labels
    
    JSQMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return kJSQMessagesCollectionViewAvatarSizeDefault;
}




#pragma mark - Other methods

- (BOOL)incoming:(JSQMessage *)message {
    
    
    return ([message.senderId isEqualToString:self.senderId] == NO);
}


@end
