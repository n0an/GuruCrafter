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




@interface ANPostCommentsViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) NSMutableArray* commentsArray;
@property (assign, nonatomic) BOOL loadingData;
@property (assign, nonatomic) NSInteger sectionsCount;

@end


static NSInteger commentsInRequest = 10;


@implementation ANPostCommentsViewController


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
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
    
    if (self.sectionsCount == 3) {
        self.sectionsCount = 4;
    } else {
        self.sectionsCount = 3;
    }
    
    
    [self.tableView reloadData];
    
    
}





#pragma mark - API


- (void) getCommentsFromServer {
    
    [[ANServerManager sharedManager] getCommentsForGroup:self.groupID
              PostID:self.postID
          withOffset:[self.commentsArray count]
               count:commentsInRequest
           onSuccess:^(NSArray *comments) {
               
               [self.commentsArray addObjectsFromArray:comments];
               
               NSMutableArray* newPaths = [NSMutableArray array];
               
               for (int i = (int)[self.commentsArray count] - (int)[comments count]; i < [self.commentsArray count]; i++) {
                   [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:2]];
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


- (void) refreshComments {
    
    self.loadingData = YES;
    
    [[ANServerManager sharedManager] getCommentsForGroup:self.groupID
              PostID:self.postID
          withOffset:0
               count:MAX(commentsInRequest, [self.commentsArray count])
           onSuccess:^(NSArray *comments) {
               
               [self.commentsArray removeAllObjects];
               
               [self.commentsArray addObjectsFromArray:comments];
               
               [self.tableView reloadData];
               
               [self.refreshControl endRefreshing];
               
               self.loadingData = NO;

               
           }
           onFailure:^(NSError *error, NSInteger statusCode) {
               
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
    
    

    if (indexPath.section == 0) { // *** POST CELL
        
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
        
        
        postCell.dateLabel.text = self.post.date;
        
        postCell.commentsCountLabel.text = self.post.comments;
        postCell.likesCountLabel.text = self.post.likes;
        
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

        
    } else if (indexPath.section == 1) { // *** SEPARATOR SECTION
        
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
        
        
    } else if (indexPath.section == 2) { // *** COMMENTS SECTION
        
        
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




#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
        if (!self.loadingData)
        {
            self.loadingData = YES;
            [self getCommentsFromServer];
        }
    }
}




@end
