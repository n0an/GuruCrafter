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

typedef enum {
    ANTableViewSectionPostInfo,
    ANTableViewSectionSeparator,
    ANTableViewSectionComments

} ANTableViewSection;


@interface ANPostCommentsViewController () <UITextFieldDelegate, UIScrollViewDelegate, ANNewMessageDelegate, ANPostCellDelegate>

@property (strong, nonatomic) NSMutableArray* commentsArray;
@property (assign, nonatomic) BOOL loadingData;


@property (strong, nonatomic) ANPostCell* postCell;

@property (assign, nonatomic) BOOL isLikedPost;

@property (strong, nonatomic) UIRefreshControl* refreshControl;

@property (assign, nonatomic) UIEdgeInsets initialInsets;
@property (assign, nonatomic) CGPoint initialContentOffset;

@property (assign, nonatomic) BOOL isFirstTimeAfterLoading;

@end


static NSInteger commentsInRequest = 10;
static NSString* iosDevCourseGroupID = @"58860049";
static NSString* myVKAccountID = @"21743772";



@implementation ANPostCommentsViewController


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.sendButton.layer.cornerRadius = 10;
    self.sendButton.enabled = NO;

    self.commentsArray = [NSMutableArray array];
    
    self.loadingData = YES;

    [self getCommentsFromServer];
    
    UIRefreshControl* refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshComments) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:refresh];
    
    self.refreshControl = refresh;
    
    
    self.navigationItem.title = [NSString stringWithFormat:@"Post #%@", self.postID];
    
    
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
    
    
    
    /****** TABLEVIEW CONTENT OFFSET AFTER KEYBOARD BECOME/RESIGN FIRST RESPONDER
     *
     *       Need to troubleshoot tableview content offset
     *
     
    CGSize keyboardSize = keyboardRect.size;
    
//    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0, keyboardSize.height, 0);
//    self.initialInsets = self.tableView.contentInset;
    
//    self.tableView.contentInset = contentInsets;
//    self.tableView.scrollIndicatorInsets = contentInsets;
    
    
    if (self.isFirstTimeAfterLoading) {
        self.initialContentOffset  = self.tableView.contentOffset;
        self.isFirstTimeAfterLoading = NO;
    }
    
//    NSLog(@"self.tableView.contentOffset = {%f, %f}", self.tableView.contentOffset.x, self.tableView.contentOffset.y);
//    
//    NSLog(@"self.initialContentOffset = {%f, %f}", self.initialContentOffset.x, self.initialContentOffset.y);
    
    CGPoint scrollPoint = CGPointMake(0, self.toolBarView.frame.origin.y - keyboardSize.height - self.initialContentOffset.y);
    NSLog(@"scrollPoint = %f, %f", scrollPoint.x, scrollPoint.y);

    [self.tableView setContentOffset:scrollPoint animated:YES];
*/
    
}

- (void) keyboardWillHide:(NSNotification*) notification {
    


    [UIView animateWithDuration:0.3f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         self.toolbarViewToBottomConstraint.constant = 0;
                         
                         [self.view layoutIfNeeded];
                         
                     } completion:nil];
    
    /****** TABLEVIEW CONTENT OFFSET AFTER KEYBOARD BECOME/RESIGN FIRST RESPONDER
     *
     *       Need to troubleshoot tableview content offset
     *
     
     //    self.tableView.contentInset = self.initialInsets;
     //
     //    self.tableView.scrollIndicatorInsets = self.initialInsets;
     
     NSLog(@"self.initialContentOffset = {%f, %f}", self.initialContentOffset.x, self.initialContentOffset.y);
     
     [self.tableView setContentOffset:self.initialContentOffset animated:YES];
     
     */
    
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
               
          }
           onFailure:^(NSError *error, NSInteger statusCode) {
              
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
                   [self.refreshControl endRefreshing];
                   
                   self.loadingData = NO;
                   
               }
               onFailure:^(NSError *error, NSInteger statusCode) {
                   
                   NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
                   [self.refreshControl endRefreshing];

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
        
        
        // *** ADDING IMAGES
        // **** IF ONLY ONE PHOTO. PLACING IT TO MAIN IMAGEVIEW
        postCell.postImageView.image = nil;
        
        if (self.post.postMainImageURL) {
            [postCell.postImageView setImageWithURL:self.post.postMainImageURL];
        }
        
        // **** IF THERE'RE MANY PHOTOS - PLACE THE FIRST ONE TO THE MAIN IMAGEVIEW, THEN
        // **** TAKE THE FOLLOWING 3, AND FILL GALLERY BY THEM
        postCell.galleryImageViewFirst.image = nil;
        postCell.galleryImageViewSecond.image = nil;
        postCell.galleryImageViewThird.image = nil;
        
        if ([self.post.attachmentsArray count] > 1) {
            for (int i = 1; i < MIN(4, [self.post.attachmentsArray count]) ; i++) {
                ANPhoto* photo = [self.post.attachmentsArray objectAtIndex:i];
                NSURL* photoURL = [NSURL URLWithString:photo.photo_604];
                
                UIImageView* imageView = [postCell.galleryImageViews objectAtIndex:i-1];
                
                [imageView setImageWithURL:photoURL];
                
            }
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



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    NSLog(@"indexPath.section = %d, indexPath.row = %d", indexPath.section, indexPath.row);
    
    
    if (indexPath.section == ANTableViewSectionComments) {

        ANComment* comment = [self.commentsArray objectAtIndex:indexPath.row];
        NSLog(@"comment.author = %@", comment.author.firstName);

        
        if (indexPath.row == [self.commentsArray count] - 1) {
            
            NSLog(@"%d", indexPath.row);
            NSLog(@"END OF COMMENTS");
            
            if (self.loadingData == NO) {
                self.loadingData = YES;
                NSLog(@"LOADING!");

                [self getCommentsFromServer];
            }
            
        }
    }
 
}



#pragma mark - UIScrollViewDelegate

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    
//    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
//        NSLog(@"scrollViewDidScroll");
//        if (!self.loadingData)
//        {
//            self.loadingData = YES;
//            [self getCommentsFromServer];
//        }
//    }
//}






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
