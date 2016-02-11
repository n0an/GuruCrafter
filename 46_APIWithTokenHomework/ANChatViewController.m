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







@end
