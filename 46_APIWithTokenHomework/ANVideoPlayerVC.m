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


typedef enum {
    ANVideoTableViewSectionVideo,
    ANVideoTableViewSectionSeparator,
    ANVideoTableViewSectionComments
    
} ANVideoTableViewSection;

@interface ANVideoPlayerVC ()

@property (strong, nonatomic) NSMutableArray* commentsArray;
@property (assign, nonatomic) BOOL loadingData;

@property (assign, nonatomic) BOOL isLikedPost;

@property (strong, nonatomic) UIRefreshControl* refreshControl;


@end



static NSInteger commentsInRequest = 10;
static NSString* iosDevCourseGroupID = @"58860049";
static NSString* myVKAccountID = @"21743772";



@implementation ANVideoPlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"ANVideoPlayerVC videoPlayerURLString = %@", self.selectedVideo.videoPlayerURLString);
    
    
    
    self.commentsArray = [NSMutableArray array];
    
    self.loadingData = YES;
    
    [self getCommentsFromServer];

    
    
    UIRefreshControl* refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshComments) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:refresh];
    
    self.refreshControl = refresh;


    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancelPressed:)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





#pragma mark - Helper Methods




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
                   
               }
               onFailure:^(NSError *error, NSInteger statusCode) {
                   
                   NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
                   
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
                                    onGroupWall:iosDevCourseGroupID
                                        forPost:self.selectedVideo.videoID
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
         NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
         
     }];
    
}





#pragma mark - Actions

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
        
         videoPlayerCell.titleLabel.text = self.selectedVideo.title;
         videoPlayerCell.descriptionLabel.text = self.selectedVideo.videoDescription;
         videoPlayerCell.likesCountLabel.text = self.selectedVideo.likesCount;
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



// SCROLLING HANDLE
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"indexPath.section = %d, indexPath.row = %d", indexPath.section, indexPath.row);
    
    if (indexPath.section == ANVideoTableViewSectionComments) {
        
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








@end
