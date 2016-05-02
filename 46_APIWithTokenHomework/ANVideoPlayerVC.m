//
//  ANVideoPlayerVC.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 03/03/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANVideoPlayerVC.h"
#import "ANVideo.h"
#import "ANServerManager.h"

#import "ANCommentCell.h"
#import "ANVideoPlayerCell.h"

#import "ANComment.h"
#import "ANGroup.h"
#import "ANUser.h"

#import "UIImageView+AFNetworking.h"

#import <UIScrollView+SVInfiniteScrolling.h>
#import <UIScrollView+SVPullToRefresh.h>


typedef enum {
    ANVideoTableViewSectionVideo,
    ANVideoTableViewSectionSeparator,
    ANVideoTableViewSectionComments
    
} ANVideoTableViewSection;

@interface ANVideoPlayerVC ()

@property (strong, nonatomic) NSMutableArray* commentsArray;
@property (assign, nonatomic) BOOL loadingData;

@property (assign, nonatomic) BOOL isLikedPost;



@end



static NSInteger commentsInRequest = 10;
static NSString* iosDevCourseGroupID = @"58860049";
static NSString* myVKAccountID = @"21743772";



@implementation ANVideoPlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.commentsArray = [NSMutableArray array];
    self.loadingData = YES;
    [self getCommentsFromServer];

    [self infiniteScrolling];

    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancelPressed:)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    
    UITapGestureRecognizer* tapGestureOnTableView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapOnTableView)];
    
    [self.tableView addGestureRecognizer:tapGestureOnTableView];
    
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillShow:)
     name:UIKeyboardWillShowNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillHide:)
     name:UIKeyboardWillHideNotification
     object:nil];
    
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Helper Methods


- (void)infiniteScrolling {
    
    __weak ANVideoPlayerVC* weakSelf = self;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        
        [weakSelf refreshComments];
        
        // once refresh, allow the infinite scroll again
        weakSelf.tableView.showsInfiniteScrolling = YES;
    }];
    
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        
        [weakSelf getCommentsFromServer];
        
    }];
}


- (void) prepareAndSendMessage {
    
    NSString* messageToSend = self.messageTextField.text;
    
    [self addComment:messageToSend];
    
    self.sendButton.enabled = NO;
    
    self.messageTextField.text = nil;
    
    [self.messageTextField resignFirstResponder];
}




#pragma mark - Actions


- (IBAction)actionSendButtonPressed:(UIButton*)sender {
    
    NSLog(@"actionSendButtonPressed");
    
    if ([self.messageTextField.text length] > 0) {
        
        [self prepareAndSendMessage];
        
    }
    
}


- (IBAction)actionMsgTxtFieldEditingChanged:(UITextField*)sender {
    
    NSLog(@"actionMsgTxtFieldEditingChanged");
    
    if ([self.messageTextField.text length] > 0) {
        self.sendButton.enabled = YES;
    } else {
        self.sendButton.enabled = NO;
    }
    
}





- (void) actionCancelPressed:(UIBarButtonItem*) sender {
    NSLog(@"actionCancelPressed");
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void) actionLikeCommentPressed:(UIButton*) sender {
    
    CGPoint btnPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    
    NSIndexPath *btnIndexPath = [self.tableView indexPathForRowAtPoint:btnPosition];
    
    ANComment* comment = [self.commentsArray objectAtIndex:btnIndexPath.row];
    
    if (comment.isLikedByMyself) {
        [self deleteLikeForItemType:@"video_comment" andItemID:comment.postID];
    } else {
        [self addLikeForItemType:@"video_comment" andItemID:comment.postID];
    }
    
    
}

- (void) actionLikeVideoPressed:(UIButton*) sender {
    
    if (self.selectedVideo.isLikedByMyself) {
        [self deleteLikeForItemType:@"video" andItemID:self.selectedVideo.videoID];
    } else {
        [self addLikeForItemType:@"video" andItemID:self.selectedVideo.videoID];
    }
    
    
}

- (void) actionTapOnTableView {
    
    NSLog(@"actionTapOnTableView");
    
    [self.messageTextField resignFirstResponder];
    
}




#pragma mark - Notifications actions

- (void) keyboardWillShow:(NSNotification*) notification {
    
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:0.3f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         self.toolbarViewToBottomConstraint.constant = keyboardRect.size.height;
                         
                         [self.view layoutIfNeeded];
                         
                     } completion:nil];
    
    
}

- (void) keyboardWillHide:(NSNotification*) notification {
    
    
    
    [UIView animateWithDuration:0.3f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         self.toolbarViewToBottomConstraint.constant = 0;
                         
                         [self.view layoutIfNeeded];
                         
                     } completion:nil];
    
}






#pragma mark - API


- (void) getCommentsFromServer {
    
    [[ANServerManager sharedManager] getCommentsForVideo:self.selectedVideo.videoID
                 groupID:iosDevCourseGroupID
              withOffset:[self.commentsArray count]
                   count:commentsInRequest
               onSuccess:^(NSArray *comments) {
                   
                   if ([comments count] > 0) {
                       
                       [self.commentsArray addObjectsFromArray:comments];
                       
                       NSMutableArray* newPaths = [NSMutableArray array];
                       
                       for (int i = (int)[self.commentsArray count] - (int)[comments count]; i < [self.commentsArray count]; i++) {
                           [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:ANVideoTableViewSectionComments]];
                       }
                       
                       [self.tableView beginUpdates];
                       [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationBottom];
                       [self.tableView endUpdates];
                       
                       
                   }
                   self.loadingData = NO;
                   [self.tableView.infiniteScrollingView stopAnimating];

                   
               }
               onFailure:^(NSError *error, NSInteger statusCode) {
                   
                   NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
                   self.tableView.showsInfiniteScrolling = NO;
                   [self.tableView.infiniteScrollingView stopAnimating];
                   
               }];
    
}



- (void) refreshComments {
    
    if (self.loadingData == NO) {
        self.loadingData = YES;
        
        [[ANServerManager sharedManager] getCommentsForVideo:self.selectedVideo.videoID
                     groupID:iosDevCourseGroupID
                  withOffset:0
                       count:MAX(commentsInRequest, [self.commentsArray count])
                   onSuccess:^(NSArray *comments) {
                       
                       if ([comments count] > 0) {
                           [self.commentsArray removeAllObjects];
                           
                           [self.commentsArray addObjectsFromArray:comments];
                           
                           [self.tableView reloadData];
                           
                       }
                       
                       self.loadingData = NO;
                       [self.tableView.pullToRefreshView stopAnimating];

                       
                   }
                   onFailure:^(NSError *error, NSInteger statusCode) {
                       
                       NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);

                       [self.tableView.pullToRefreshView stopAnimating];

                       
                   }];
        
    }
    
    
}


- (void) addComment:(NSString*) message {
    
    [[ANServerManager sharedManager] addComment:message
               forGroup:iosDevCourseGroupID
               forVideo:self.selectedVideo.videoID
              onSuccess:^(id result) {
                  
                  NSLog(@"COMMENT ADDED");
                  
                  [self refreshComments];
                  
              }

              onFailure:^(NSError *error, NSInteger statusCode) {
                  NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);

              }];
    
    
}


- (void) addLikeForItemType:(NSString*) itemType andItemID:(NSString*) itemID {
    
    self.loadingData = YES;
    
    [[ANServerManager sharedManager]
     addLikeForItemType:itemType
     forOwnerID:iosDevCourseGroupID
     forItemID:itemID
     onSuccess:^(NSDictionary* result) {
         NSLog(@"Like added successfully!");
         
         NSString* likesCount = [[result objectForKey:@"likes"] stringValue];
         
         if ([itemType isEqualToString:@"video"]) {
             self.selectedVideo.isLikedByMyself = YES;
             self.selectedVideo.likesCount = likesCount;
             
         } else if ([itemType isEqualToString:@"video_comment"]) {
             
             NSIndexPath* changingInxPath;
             for (ANComment* comment in self.commentsArray) {
                 if ([comment.postID isEqualToString:itemID]) {
                     
                     
                     comment.isLikedByMyself = YES;
                     comment.likes = likesCount;
                     
                     NSInteger index = [self.commentsArray indexOfObject:comment];
                     
                     changingInxPath = [NSIndexPath indexPathForRow:index inSection:ANVideoTableViewSectionComments];
                     NSLog(@"changingInxPath = %@", changingInxPath);
                 }
             }
             
         }
         
         [self.tableView reloadData];
         
         self.loadingData = NO;
         
     }
     onFailure:^(NSError *error, NSInteger statusCode)
     {
         NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
         
     }];
    
}



- (void) deleteLikeForItemType:(NSString*) itemType andItemID:(NSString*) itemID {
    
    self.loadingData = YES;
    
    [[ANServerManager sharedManager]
     deleteLikeForItemType:itemType
     forOwnerID:iosDevCourseGroupID
     forItemID:itemID
     onSuccess:^(NSDictionary* result) {
         NSLog(@"Like deleted successfully!");
         
         NSString* likesCount = [[result objectForKey:@"likes"] stringValue];
         
         if ([itemType isEqualToString:@"video"]) {
             
             self.selectedVideo.isLikedByMyself = NO;
             self.selectedVideo.likesCount = likesCount;
             
         } else if ([itemType isEqualToString:@"video_comment"]) {
             
             for (ANComment* comment in self.commentsArray) {
                 if ([comment.postID isEqualToString:itemID]) {
                     comment.isLikedByMyself = NO;
                     comment.likes = likesCount;
                 }
             }
             
         }
         
         [self.tableView reloadData];
         
         self.loadingData = NO;
         
         
     }
     onFailure:^(NSError *error, NSInteger statusCode)
     {
         NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
         
     }];
    
}







#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == ANVideoTableViewSectionComments) {
        return [self.commentsArray count];
        
    }
    
    return 1;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *videoIdentifier =      @"videoPlayerCell";
    static NSString *separatorIdentifier =  @"separatorCell";
    static NSString *commentIdentifier =    @"commentCell";
    
    
    if (indexPath.section == ANVideoTableViewSectionVideo) { // *** VIDEO CELL
        
        ANVideoPlayerCell* videoPlayerCell = [tableView dequeueReusableCellWithIdentifier:videoIdentifier];
        
         
        NSString* newString = [self.selectedVideo.videoPlayerURLString stringByAppendingString:@"&showinfo=0"];
         
        NSURL* urlVideo = [NSURL URLWithString:newString];
         
        NSURLRequest* requestToYoutube = [NSURLRequest requestWithURL:urlVideo];
        
        [videoPlayerCell.playerWebView loadRequest:requestToYoutube];
        
        [videoPlayerCell.playerWebView.scrollView setScrollEnabled:NO];

        
        videoPlayerCell.titleLabel.text = self.selectedVideo.title;
        videoPlayerCell.descriptionLabel.text = self.selectedVideo.videoDescription;
        
        [videoPlayerCell.likeButton setTitle:self.selectedVideo.likesCount forState:UIControlStateNormal];
        [videoPlayerCell.likeButton addTarget:self action:@selector(actionLikeVideoPressed:) forControlEvents:UIControlEventTouchUpInside];

        
        if (self.selectedVideo.isLikedByMyself) {
            [videoPlayerCell.likeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [videoPlayerCell.likeButton setImage:[UIImage imageNamed:@"thumb-up_b.png"] forState:UIControlStateNormal];
            
        } else {
            [videoPlayerCell.likeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [videoPlayerCell.likeButton setImage:[UIImage imageNamed:@"thumb-up_16.png"] forState:UIControlStateNormal];
        }

        
        videoPlayerCell.viewsCountLabel.text = self.selectedVideo.views;
        videoPlayerCell.dateLabel.text = [NSString stringWithFormat:@"Added on %@", self.selectedVideo.date];
        

        return videoPlayerCell;
        
        
    } else if (indexPath.section == ANVideoTableViewSectionSeparator) { // *** SEPARATOR SECTION
        
        UITableViewCell* separatorCell = [tableView dequeueReusableCellWithIdentifier:separatorIdentifier];
        
        if (!separatorCell) {
            separatorCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:separatorIdentifier];
        }
        
        return separatorCell;
        
    } else if (indexPath.section == ANVideoTableViewSectionComments) { // *** COMMENTS SECTION
        
        ANCommentCell* commentCell = [tableView dequeueReusableCellWithIdentifier:commentIdentifier];
        
        if (!commentCell) {
            commentCell = [[ANCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commentIdentifier];
        }
        
        
        ANComment* comment = [self.commentsArray objectAtIndex:indexPath.row];
        
        
        if (comment.fromGroup != nil) {
            commentCell.fullNameLabel.text = comment.fromGroup.groupName;
            [commentCell.postAuthorImageView setImageWithURL:comment.fromGroup.imageURL];
            
        } else if (comment.author != nil) {
            commentCell.fullNameLabel.text = [NSString stringWithFormat:@"%@ %@", comment.author.firstName, comment.author.lastName];
            [commentCell.postAuthorImageView setImageWithURL:comment.author.imageURL];
            
        }
        
        commentCell.dateLabel.text = comment.date;
        
        
        [commentCell.likeButton setTitle:comment.likes forState:UIControlStateNormal];
        [commentCell.likeButton addTarget:self action:@selector(actionLikeCommentPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        
        if (comment.isLikedByMyself) {
            [commentCell.likeButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [commentCell.likeButton setImage:[UIImage imageNamed:@"like_b_16.png"] forState:UIControlStateNormal];
            
        } else {
            [commentCell.likeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [commentCell.likeButton setImage:[UIImage imageNamed:@"like_16.png"] forState:UIControlStateNormal];
            
        }
        
        commentCell.commentTextLabel.text = comment.text;
        
        return commentCell;
        
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == ANVideoTableViewSectionSeparator) {
        return 10;
    }
    
    return UITableViewAutomaticDimension;
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == ANVideoTableViewSectionSeparator) {
        return 10;
    }
    return UITableViewAutomaticDimension; // Auto Layout elements in the cell
}





#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([self.messageTextField.text length] > 0) {
        
        [self prepareAndSendMessage];
        
    } else {
        
        [textField resignFirstResponder];
    }
    
    
    return YES;
}





@end
