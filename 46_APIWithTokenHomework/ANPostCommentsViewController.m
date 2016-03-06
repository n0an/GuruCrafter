//
//  ANPostCommentsViewController.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 15/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANPostCommentsViewController.h"
#import "ANServerManager.h"
#import "ANPostCell.h"
#import "ANCommentCell.h"
#import "ANPost.h"
#import "ANGroup.h"
#import "ANUser.h"
#import "ANPhoto.h"
#import "ANComment.h"

#import "UIImageView+AFNetworking.h"

#import "ANNewMessageCell.h"

#import "ANPostPhotoGallery.h"
#import "ANPhotoInPostVC.h"
#import "ANJSQMessagesVC.h"

#import <UIScrollView+SVInfiniteScrolling.h>
#import <UIScrollView+SVPullToRefresh.h>

#import "UITableViewCell+CellForContent.h"



typedef enum {
    ANTableViewSectionPostInfo,
    ANTableViewSectionSeparator,
    ANTableViewSectionComments

} ANTableViewSection;


@interface ANPostCommentsViewController () <UITextFieldDelegate, ANNewMessageDelegate, ANPostCellDelegate>

@property (strong, nonatomic) NSMutableArray* commentsArray;
@property (assign, nonatomic) BOOL loadingData;


@property (strong, nonatomic) ANPostCell* postCell;

@property (assign, nonatomic) BOOL isLikedPost;

@property (strong, nonatomic) UIRefreshControl* refreshControl;

@end


static NSInteger commentsInRequest = 10;
static NSString* iosDevCourseGroupID = @"58860049";
static NSString* myVKAccountID = @"21743772";



@implementation ANPostCommentsViewController


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title = [NSString stringWithFormat:@"Post #%@", self.postID];

    self.sendButton.layer.cornerRadius = 10;
    self.sendButton.enabled = NO;

    self.commentsArray = [NSMutableArray array];
    self.loadingData = YES;
    [self getCommentsFromServer];
    
    [self infiniteScrolling];
    
    
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

- (void) dealloc {
    
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
}



#pragma mark - Helper Methods


- (void)infiniteScrolling {
    
    __weak ANPostCommentsViewController* weakSelf = self;
    
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



- (void) actionLikeCommentPressed:(UIButton*) sender {
    
    CGPoint btnPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    
    NSIndexPath *btnIndexPath = [self.tableView indexPathForRowAtPoint:btnPosition];
    
    ANComment* comment = [self.commentsArray objectAtIndex:btnIndexPath.row];
    
    if (comment.isLikedByMyself) {
        [self deleteLikeForItemType:@"comment" andItemID:comment.postID];
    } else {
        [self addLikeForItemType:@"comment" andItemID:comment.postID];
    }
    
    
}





#pragma mark - Gestures

- (void) actionGlryImageViewTapped:(UITapGestureRecognizer*) recognizer {
    
    UIImageView* tappedImageView = (UIImageView*)recognizer.view;
    
    // Getting cell that has this image view. Double superview because - Cell->ContentView->ImageView
    ANPostCell* cell = (ANPostCell*)tappedImageView.superview.superview;
    
    ANPost* clickedPost = self.post;
    
    NSInteger clickedIndex = [cell.glryImageViews indexOfObject:tappedImageView];
    
    ANPhoto* clickedPhoto = [clickedPost.attachmentsArray objectAtIndex:clickedIndex];
    
    ANPhotoInPostVC* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ANPhotoInPostVC"];
    
    vc.currentPhoto = clickedPhoto;
    vc.photosArray = clickedPost.attachmentsArray;
    
    [self.navigationController pushViewController:vc animated:YES];
    
    
}



- (void) actionTapOnTableView {
    
    NSLog(@"actionTapOnTableView");
    
    [self.messageTextField resignFirstResponder];
    
}


- (void) handleTapOnImageView:(UITapGestureRecognizer*) recognizer {
    
    NSLog(@"TAP WORKS!!");
    
    ANPost* clickedPost = self.post;
    
    ANJSQMessagesVC* vc = [[ANJSQMessagesVC alloc] init];
    
    vc.senderId = clickedPost.author.userID;
    
    vc.senderDisplayName = [NSString stringWithFormat:@"%@ %@", clickedPost.author.firstName, clickedPost.author.lastName];
    
    vc.avatarIncoming = clickedPost.author.imageURL;
    
    vc.avatarOutgoing = [[[ANServerManager sharedManager] currentUser] imageURL];
    
    
    [self.navigationController pushViewController:vc animated:YES];
    
}


- (void) handleTapOnCommentImageView:(UITapGestureRecognizer*) recognizer {
    
    NSLog(@"TAP WORKS!!");
    
    // Taking tapped image view from activated recognizer
    UIImageView* tappedImageView = (UIImageView*)recognizer.view;
    
    ANCommentCell* clickedCommentCell = (ANCommentCell*)[UITableViewCell getParentCellFor:tappedImageView];
    
    NSIndexPath* clickedIndexPath = [self.tableView indexPathForCell:clickedCommentCell];
    
    ANComment* clickedComment = [self.commentsArray objectAtIndex:clickedIndexPath.row];
    
    ANJSQMessagesVC* vc = [[ANJSQMessagesVC alloc] init];
    
    vc.senderId = clickedComment.author.userID;
    
    vc.senderDisplayName = [NSString stringWithFormat:@"%@ %@", clickedComment.author.firstName, clickedComment.author.lastName];
    
    vc.avatarIncoming = clickedComment.author.imageURL;
    
    vc.avatarOutgoing = [[[ANServerManager sharedManager] currentUser] imageURL];
    
    
    [self.navigationController pushViewController:vc animated:YES];

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
    
    [[ANServerManager sharedManager] getCommentsForGroup:self.groupID
              PostID:self.postID
          withOffset:[self.commentsArray count]
               count:commentsInRequest
           onSuccess:^(NSArray *comments) {
               
               if ([comments count] > 0) {
                   
                   [self.commentsArray addObjectsFromArray:comments];
                   
                   NSMutableArray* newPaths = [NSMutableArray array];
                   
                   for (int i = (int)[self.commentsArray count] - (int)[comments count]; i < [self.commentsArray count]; i++) {
                       [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:ANTableViewSectionComments]];
                   }
                   
                   [self.tableView beginUpdates];
                   [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationBottom];
                   [self.tableView endUpdates];
                   
                   
               }
               self.loadingData = NO;
               [self.tableView.infiniteScrollingView stopAnimating];
               
               
          }
           onFailure:^(NSError *error, NSInteger statusCode) {
               self.tableView.showsInfiniteScrolling = NO;
               [self.tableView.infiniteScrollingView stopAnimating];

               NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
               
          }];

}



- (void) refreshComments {
    
    if (self.loadingData == NO) {
        self.loadingData = YES;
        
        [[ANServerManager sharedManager] getCommentsForGroup:self.groupID
                  PostID:self.postID
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
                   [self.tableView.pullToRefreshView stopAnimating];

                   NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);

               }];

    }
    
    
}


- (void) addComment:(NSString*) message {
    
    [[ANServerManager sharedManager] addComment:message
            onGroupWall:self.groupID
                forPost:self.postID
              onSuccess:^(id result) {
                  
                  NSLog(@"COMMENT ADDED");

                  [self refreshComments];
                  
              }
              onFailure:^(NSError *error, NSInteger statusCode) {
                  NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);

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
         
         if ([itemType isEqualToString:@"post"]) {
             self.post.isLikedByMyself = YES;
             self.post.likes = likesCount;
             
         } else if ([itemType isEqualToString:@"comment"]) {
             
             NSIndexPath* changingInxPath;
             for (ANComment* comment in self.commentsArray) {
                 if ([comment.postID isEqualToString:itemID]) {
                     comment.isLikedByMyself = YES;
                     comment.likes = likesCount;
                     
                     NSInteger index = [self.commentsArray indexOfObject:comment];
                     

                     
                     changingInxPath = [NSIndexPath indexPathForRow:index inSection:ANTableViewSectionComments];
                     NSLog(@"changingInxPath = %@", changingInxPath);
                 }
             }

         }

         [self.tableView reloadData];
         
         self.loadingData = NO;
         
     }
     onFailure:^(NSError *error, NSInteger statusCode)
     {
         NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
         
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
         
         if ([itemType isEqualToString:@"post"]) {
             
             self.post.isLikedByMyself = NO;
             self.post.likes = likesCount;
             
         } else if ([itemType isEqualToString:@"comment"]) {
             
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
         NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
         
     }];
    
}




#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == ANTableViewSectionComments) {
        return [self.commentsArray count];
    }
    
    return 1;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *postIdentifier =       @"postCell";
    static NSString *separatorIdentifier =  @"separatorCell";
    static NSString *commentIdentifier =    @"commentCell";
    

    if (indexPath.section == ANTableViewSectionPostInfo) { // *** POST CELL
        
        ANPostCell* postCell = [tableView dequeueReusableCellWithIdentifier:postIdentifier];

        if (!postCell) {
            postCell = [[ANPostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:postIdentifier];
        }

        if (self.post.fromGroup != nil) {
            postCell.fullNameLabel.text = self.post.fromGroup.groupName;
            [postCell.postAuthorImageView setImageWithURL:self.post.fromGroup.imageURL];
            
            
        } else if (self.post.author != nil) {
            postCell.fullNameLabel.text = [NSString stringWithFormat:@"%@ %@", self.post.author.firstName, self.post.author.lastName];
            [postCell.postAuthorImageView setImageWithURL:self.post.author.imageURL];
            
        }
        
        
        // *** CREATING GESTURE RECOGNIZER FOR HADLE AUTHOR IMAGEVIEW TAP
        
        postCell.postAuthorImageView.userInteractionEnabled = YES;
        
        UIGestureRecognizer* tapAuthorImageViewGesutre =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnImageView:)];
        [postCell.postAuthorImageView addGestureRecognizer:tapAuthorImageViewGesutre];

        
        postCell.delegate = self;
        postCell.postID = self.postID;
        
        
        postCell.dateLabel.text = self.post.date;
        
        postCell.commentsCountLabel.text = self.post.comments;
        
        
        [postCell.likeButton setTitle:self.post.likes forState:UIControlStateNormal];
        

        if (self.post.isLikedByMyself) {
            [postCell.likeButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [postCell.likeButton setImage:[UIImage imageNamed:@"like_b_16.png"] forState:UIControlStateNormal];
            
        } else {
            [postCell.likeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [postCell.likeButton setImage:[UIImage imageNamed:@"like_16.png"] forState:UIControlStateNormal];
        }
        
        postCell.postTextLabel.text = self.post.text;
        
        
        // *** ADDING POST IMAGE GALLERY
        ANPostPhotoGallery* postGallery = [[ANPostPhotoGallery alloc] initWithTableViewWidth:CGRectGetWidth(self.tableView.frame)];
        
        [postGallery insertGalleryOfPost:self.post toCell:postCell];
        
        for (UIImageView* photoImageView in postCell.glryImageViews) {
            photoImageView.userInteractionEnabled = YES;
            
            UITapGestureRecognizer* tapGesture =
            [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(actionGlryImageViewTapped:)];
            
            [photoImageView addGestureRecognizer:tapGesture];
            
        }
        

        return postCell;

        
    } else if (indexPath.section == ANTableViewSectionSeparator) { // *** SEPARATOR SECTION
        
        UITableViewCell* separatorCell = [tableView dequeueReusableCellWithIdentifier:separatorIdentifier];
        
        if (!separatorCell) {
            separatorCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:separatorIdentifier];
        }
        
        return separatorCell;
        
    } else if (indexPath.section == ANTableViewSectionComments) { // *** COMMENTS SECTION
        
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
        
        // *** CREATING GESTURE RECOGNIZER FOR HADLE COMMENT AUTHOR IMAGEVIEW TAP
        
        commentCell.postAuthorImageView.userInteractionEnabled = YES;
        
        UIGestureRecognizer* tapCommentAuthorImageViewGesutre =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnCommentImageView:)];
        [commentCell.postAuthorImageView addGestureRecognizer:tapCommentAuthorImageViewGesutre];
        

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
    
    if (indexPath.section == 1) {
        return 10;
    }
    
    return UITableViewAutomaticDimension;
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
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


#pragma mark - +++ ANNewMessageDelegate +++
- (void) sendButtonPressedWithMessage:(NSString*) message {
    NSLog(@"sendButtonPressedWithMessage");
    NSLog(@"received message = %@",message);
    
    [self addComment:message];
    
    
    
}


#pragma mark - +++ ANPostCellDelegate +++

- (void) likeButtonPressedForPostID:(NSString*) postID {
    
    if (self.post.isLikedByMyself) {
        [self deleteLikeForItemType:@"post" andItemID:self.postID];
    } else {
        [self addLikeForItemType:@"post" andItemID:self.postID];
    }
    
}





@end
