//
//  ANChatViewController.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 10/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANChatViewController.h"
#import "JSQMessagesCollectionView.h"
#import "ANServerManager.h"
#import "ANPost.h"
#import "ANPrivateMessage.h"


@interface ANChatViewController ()

@property (strong, nonatomic) NSMutableArray* privateMessagesArray;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@property (strong, nonatomic) NSOperation *currentOperation;
@property (strong, nonatomic) NSOperationQueue *queue;

@property (strong, nonatomic) UIImage* photoSelfImage;
@property (strong, nonatomic) UIImage* photoPartnerImage;

@end

@implementation ANChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.testMessageLabel.text = self.userID;
    
    self.navigationItem.title = self.senderDisplayName;
    self.privateMessagesArray = [NSMutableArray array];
    
    self.photoSelfImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.photoSelfURL]];
    
    self.photoPartnerImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.photoPartnerURL]];
    
    [self getPrivateMessagesBackgroundFromServer:20 offset:0];
    
    JSQMessagesBubbleImageFactory *bubbleFactory= [[JSQMessagesBubbleImageFactory alloc] init];
    
    self.outgoingBubbleImageData=[bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.incomingBubbleImageData=[bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    self.collectionView.collectionViewLayout.springinessEnabled = YES;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Actions

- (IBAction)actionCancel:(UIBarButtonItem *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}



#pragma mark - API

- (void) getPrivateMessagesBackgroundFromServer:(NSInteger) count offset: (NSInteger) offset {
    
    self.queue = [[NSOperationQueue alloc] init];
    
    __weak NSOperation *weakCurrentOperation = self.currentOperation;
    
    __weak ANChatViewController* weakSelf = self;
    
    self.currentOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        if (![weakCurrentOperation isCancelled]) {
            [weakSelf getPrivateMessagesFromServer:count offset:offset];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.collectionView reloadData];
        });
        
    }];
    
    [self.queue addOperation:self.currentOperation];
    
    
}

- (void) getPrivateMessagesFromServer:(NSInteger) count offset: (NSInteger) offset {

    [[ANServerManager sharedManager]
     getPrivateMessagesFromUser:self.senderId
     senderName:self.senderDisplayName
     withOffset:offset
     count:count
     onSuccess:^(NSArray *privateMessages) {
         
         [self.privateMessagesArray addObjectsFromArray:privateMessages];
         
         NSSortDescriptor *dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
         
         [self.privateMessagesArray sortUsingDescriptors:[NSArray arrayWithObject:dateDescriptor]];
         
         NSLog(@"messages count = %d", [self.privateMessagesArray count]);
         
         [self.collectionView reloadData];
         
         
     }
     
     onFailure:^(NSError *error, NSInteger statusCode) {
         
         NSLog(@"error = %@, code = %d", [error localizedDescription], statusCode);
                                          
     }];
    
}


#pragma mark - JSQMessages Data Source methods

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    //Return the actual message at each indexpath.row
    return [self.privateMessagesArray objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.privateMessagesArray objectAtIndex:indexPath.item];
    
    if (![self incoming:message]) {
        
        return self.outgoingBubbleImageData;
        
    } else {
        
        return self.incomingBubbleImageData;
    }
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
                    avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage *message = [self.privateMessagesArray objectAtIndex:indexPath.item];
    
    UIImage *image = nil;
    
    if (![self incoming:message]) {
        
        image = self.photoPartnerImage;
        
    } else {
        
        image = self.photoSelfImage;
    }
    
    JSQMessagesAvatarImage *avatar = [JSQMessagesAvatarImageFactory avatarImageWithImage:image diameter:20];
    return avatar;
}




- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage *message = [self.privateMessagesArray objectAtIndex:indexPath.item];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
    //cell.cellBottomLabel.text = [dateFormatter stringFromDate:message.date];
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:[dateFormatter stringFromDate:message.date]];
    return attributedString;
}


- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage *message = [self.privateMessagesArray objectAtIndex:indexPath.item];
    
    if ([self incoming:message]) {
        return nil;
    }
    if (indexPath.item - 1 > 0) {
        
        JSQMessage *previous = [self.privateMessagesArray objectAtIndex:indexPath.item-1];
        if ([previous.senderId isEqualToString:message.senderId]) {
            
            return nil;
        }
    }
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}


#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.privateMessagesArray count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *message = [self.privateMessagesArray objectAtIndex:indexPath.item];
    
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
    
    JSQMessage *currentMessage = [self.privateMessagesArray objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.privateMessagesArray objectAtIndex:indexPath.item - 1];
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
