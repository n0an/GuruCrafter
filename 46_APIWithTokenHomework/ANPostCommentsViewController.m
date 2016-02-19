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
    ANTableViewSectionNewCommentOrComments,
    ANTableViewSectionComments

} ANTableViewSection;

typedef enum {
    activatedYES = 4,
    activatedNO = 3

} ANNewCommentSectionActivated;


@interface ANPostCommentsViewController () <UIScrollViewDelegate, ANNewMessageDelegate, ANPostCellDelegate>

@property (strong, nonatomic) NSMutableArray* commentsArray;
@property (assign, nonatomic) BOOL loadingData;
@property (assign, nonatomic) NSInteger sectionsCount;
@property (assign, nonatomic) ANNewCommentSectionActivated newCommentSectionActivated;

@property (strong, nonatomic) ANPostCell* postCell;

@property (assign, nonatomic) BOOL isLikedPost;

@end


static NSInteger commentsInRequest = 10;
static NSString* iosDevCourseGroupID = @"58860049";
static NSString* myVKAccountID = @"21743772";



@implementation ANPostCommentsViewController


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.newCommentSectionActivated = activatedNO;
    self.sectionsCount = 3;
    
    self.commentsArray = [NSMutableArray array];
    
    self.loadingData = YES;

    [self getCommentsFromServer];
    
    UIRefreshControl* refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshComments) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    
    self.navigationItem.title = [NSString stringWithFormat:@"Post #%@", self.postID];
    

}


#pragma mark - Actions

- (void)actionComposePressed:(UIButton*)sender {
    NSLog(@"actionComposePressed");
    
    if (self.newCommentSectionActivated == activatedNO) {
    
        self.newCommentSectionActivated = activatedYES;
        self.sectionsCount = 4;
        
    } else {
        
        self.sectionsCount = self.newCommentSectionActivated = activatedNO;
        self.sectionsCount = 3;

    }
    
    
    [self.tableView reloadData];
    
    
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
                       [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:2]];
                   }
                   
                   [self.tableView beginUpdates];
                   [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationFade];
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
                       
                       [self.refreshControl endRefreshing];
                       
                       self.loadingData = NO;
                   }
                   

               }
               onFailure:^(NSError *error, NSInteger statusCode) {
                   
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
                  
                  self.sectionsCount = 3;
                  self.newCommentSectionActivated = NO;
                  
                  self.loadingData = YES;
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
                     NSInteger section;
                     
                     if (self.newCommentSectionActivated == activatedYES) {
                         section = 3;
                     } else {
                         section = 2;
                     }
                     
                     changingInxPath = [NSIndexPath indexPathForRow:index inSection:section];
                     NSLog(@"changingInxPath = %@", changingInxPath);
                 }
             }
             
//             [self.tableView beginUpdates];
//
//             [self.tableView reloadRowsAtIndexPaths:@[changingInxPath] withRowAnimation:UITableViewRowAnimationFade];
//
//             [self.tableView endUpdates];

             
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
    return self.sectionsCount;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    if (self.sectionsCount == 4) {
        if (section == 3) {
            return [self.commentsArray count];
        } else {
            return 1;
        }
        
    } else {
        
        if (section == 2) {
            return [self.commentsArray count];
        } else {
            return 1;
        }
    }
    
    return 1;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *postIdentifier =       @"postCell";
    static NSString *separatorIdentifier =  @"separatorCell";
    static NSString *commentIdentifier =    @"commentCell";
    
    BOOL commentsSecComposeHide =   (indexPath.section == ANTableViewSectionNewCommentOrComments) && (self.newCommentSectionActivated = activatedNO);
    BOOL commentsSecComposeShow =   (indexPath.section == ANTableViewSectionComments) && (self.newCommentSectionActivated = activatedYES);
    BOOL commentsSection = commentsSecComposeHide || commentsSecComposeShow;

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
        postCell.likesCountLabel.text = self.post.likes;
        
        
        if (self.post.isLikedByMyself) {
            postCell.likesCountLabel.textColor = [UIColor blueColor];
        } else {
            postCell.likesCountLabel.textColor = [UIColor lightGrayColor];
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
        
        UIButton* addCommentButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        addCommentButton.showsTouchWhenHighlighted = YES;
        
        [addCommentButton addTarget:self action:@selector(actionComposePressed:) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat width = tableView.frame.size.width;
        
        CGRect rect = CGRectMake(width - 25, 5, 20, 20);
        
        addCommentButton.frame = rect;
        
        [separatorCell.contentView addSubview:addCommentButton];

        
        return separatorCell;
        
        
        
    } else if (self.newCommentSectionActivated == activatedYES && indexPath.section == ANTableViewSectionNewCommentOrComments) { // *** NEW COMMENT SECTION
        
        static NSString* newMessageIdentifier = @"newMessageCell";
        
        ANNewMessageCell* newMessageCell = [tableView dequeueReusableCellWithIdentifier:newMessageIdentifier];
        
        if (!newMessageCell) {
            newMessageCell = [[ANNewMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:newMessageIdentifier];
        }
        
        newMessageCell.delegate = self;
        
        return newMessageCell;

    } else if (commentsSection) { // *** COMMENTS SECTION
        
        
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
        
        
        NSString* likesBtnLabelText = [NSString stringWithFormat:@"Likes: %@", comment.likes];
        
        [commentCell.likeButton setTitle:likesBtnLabelText forState:UIControlStateNormal];
        [commentCell.likeButton addTarget:self action:@selector(actionLikeCommentPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        
        if (comment.isLikedByMyself) {
            [commentCell.likeButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        } else {
            [commentCell.likeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }

        
        commentCell.likesCountLabel.text = comment.likes;
        
        commentCell.commentTextLabel.text = comment.text;

        return commentCell;

    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        return 30;
    }
    
    return UITableViewAutomaticDimension;
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return 30;
    }
    return UITableViewAutomaticDimension; // Auto Layout elements in the cell
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL commentsSecComposeHide =   (indexPath.section == ANTableViewSectionNewCommentOrComments) && (self.newCommentSectionActivated = activatedNO);
    BOOL commentsSecComposeShow =   (indexPath.section == ANTableViewSectionComments) && (self.newCommentSectionActivated = activatedYES);
    
    NSLog(@"indexPath.section = %d, indexPath.row = %d", indexPath.section, indexPath.row);
    
    
    if (commentsSecComposeHide || commentsSecComposeShow) {
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
