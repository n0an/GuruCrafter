//
//  ViewController.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 06/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ViewController.h"
#import "ANServerManager.h"
#import "ANUser.h"
#import "ANGroup.h"
#import "UIImageView+AFNetworking.h"

#import "ANPost.h"
#import "ANPostCell.h"

#import "ANPhoto.h"

#import "ANAddPostViewController.h"

#import "ANMessagesViewController.h"
#import "ANNewPostCell.h"

#import "ANPostCommentsViewController.h"

#import "ANPhotoAlbum.h"
#import "ANUploadServer.h"

typedef enum {
    ANTableViewSectionAddPost,
    ANTableViewSectionWall,
    
} ANTableViewSection;



@interface ViewController () <UIScrollViewDelegate, ANAddPostDelegate, ANPostCellDelegate>

@property (assign, nonatomic) BOOL firstTimeAppear;

@property (strong, nonatomic) NSMutableArray* postsArray;

@property (assign, nonatomic) BOOL loadingData;
@property (assign, nonatomic) BOOL isLikedPost;

//@property (strong,nonatomic) NSMutableArray *postImageViewsSizesArray;


@end

static NSInteger postsInRequest = 20;
static NSString* iosDevCourseGroupID = @"58860049";
static NSString* myVKAccountID = @"21743772";



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.postsArray = [NSMutableArray array];
//    self.postImageViewsSizesArray = [NSMutableArray array];
    self.firstTimeAppear = YES;
    self.loadingData = YES;
    

    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;


    UIRefreshControl* refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshWall) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    
    [[ANServerManager sharedManager] authorizeUser:^(ANUser *user) {
        
        NSLog(@"AUTHORIZED!");
        NSLog(@"%@ %@", user.firstName, user.lastName);
        
        ANServerManager* serverManager = [ANServerManager sharedManager];
        serverManager.currentUser = user;
        
        self.loadingData = NO;
        [self getPostsFromServer];

    }];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Helper Methods

- (void) performTransitionToPostDetails:(NSIndexPath*) indexPath {
    ANPost* selectedPost = [self.postsArray objectAtIndex:indexPath.row];
    
    ANPostCommentsViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ANPostCommentsViewController"];
    
    vc.groupID = iosDevCourseGroupID;
    vc.postID = selectedPost.postID;
    vc.post = selectedPost;
    
    [self.navigationController pushViewController:vc animated:YES];

}



#pragma mark - Actions

- (void) actionCommentPressed:(UIButton*) sender {
    
    CGPoint btnPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    
    NSIndexPath *btnIndexPath = [self.tableView indexPathForRowAtPoint:btnPosition];
    
    NSLog(@"actionCommentPressed");
    
    
    [self performTransitionToPostDetails:btnIndexPath];
    
}

- (IBAction)actionCameraButtonPressed:(UIBarButtonItem*)sender {
    
    [[ANServerManager sharedManager] getGroupAlbums:iosDevCourseGroupID
                                         withOffset:0
                                              count:0
          onSuccess:^(NSArray *photoAlbums) {
              
              NSLog(@"actionCameraButtonPressed");
              for (ANPhotoAlbum* album in photoAlbums) {
                  NSLog(@"photoAlbum id = %@, title = %@, size = %@", album.albumID, album.albumTitle, album.albumSize);
                  
                  [[ANServerManager sharedManager] getUploadServerForGroupID:iosDevCourseGroupID
                         forPhotoAlbumID:album.albumID
                               onSuccess:^(ANUploadServer* uploadServer) {
                                   
                                   NSLog(@"uploadServer = %@", uploadServer.uploadURL);
                                   
                               }
                   
                               onFailure:^(NSError *error, NSInteger statusCode) {
                                   
                               }];
                  
              }
              
          }
          onFailure:^(NSError *error, NSInteger statusCode) {
              
          }];
}



- (IBAction)actionVideoButtonPressed:(UIBarButtonItem*)sender {
    /*
    [[ANServerManager sharedManager] getVideoAlbumsForGroupID:iosDevCourseGroupID
       withOffset:0
            count:20
        onSuccess:^(NSArray *videoAlbums) {
            
            NSLog(@"videoAlbums = %@", videoAlbums);
            
            
            
                
        }
     
        onFailure:^(NSError *error, NSInteger statusCode) {
            
        }];
     */
    
}



#pragma mark - API


- (void) getPostsFromServer {
    
    if (self.loadingData == NO) {
        self.loadingData = YES;
        
        [[ANServerManager sharedManager]
         getGroupWall:@"58860049"
         withOffset:[self.postsArray count]
         count:postsInRequest
         onSuccess:^(NSArray *posts) {
             
             if ([posts count] > 0) {
                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                     [self.postsArray addObjectsFromArray:posts];
                     
                     NSMutableArray* newPaths = [NSMutableArray array];
                     
                     for (int i = (int)[self.postsArray count] - (int)[posts count]; i < [self.postsArray count]; i++) {
                         [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:1]];
                     }
                     
                     dispatch_sync(dispatch_get_main_queue(), ^{
                         [self.tableView beginUpdates];
                         [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationFade];
                         [self.tableView endUpdates];
                         
                         
                         self.loadingData = NO;
                     });
                     
                     
                 });
             }
             
             
         }
         onFailure:^(NSError *error, NSInteger statusCode) {
             NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
             
         }];
        
        
    }
    
 
}


- (void) refreshWall {
    
    if (self.loadingData == NO) {
        self.loadingData = YES;
        
        [[ANServerManager sharedManager]
         getGroupWall:iosDevCourseGroupID
         withOffset:0
         count:MAX(postsInRequest, [self.postsArray count])
         onSuccess:^(NSArray *posts) {
             
             if ([posts count] > 0) {
                 [self.postsArray removeAllObjects];
                 
                 [self.postsArray addObjectsFromArray:posts];
                 
                 [self.tableView reloadData];
                 
                 [self.refreshControl endRefreshing];
                 
                 self.loadingData = NO;

             }
             
         }
         onFailure:^(NSError *error, NSInteger statusCode) {
             
             NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
             
             [self.refreshControl endRefreshing];
             
         }];
        
    }
    

    
}


- (void) postOnWallMessage:(NSString*) message {
    
    [[ANServerManager sharedManager]
     postText:message
     onGroupWall:@"58860049"
     onSuccess:^(id result) {
         
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         
     }];
    
}


- (void) addLikeForPost:(ANPost*) post {
    
    [[ANServerManager sharedManager]
     addLikeForItemType:@"post"
     forOwnerID:iosDevCourseGroupID
     forItemID:post.postID
     onSuccess:^(NSDictionary* result) {
         NSLog(@"Like added successfully!");
         
         NSString* likesCount = [[result objectForKey:@"likes"] stringValue];
         
         post.likes = likesCount;
         
         post.isLikedByMyself = YES;
         
         [self.tableView reloadData];

     }
     onFailure:^(NSError *error, NSInteger statusCode)
     {
         NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
         
     }];
    
}

- (void) deleteLikeForPost:(ANPost*) post {
    
    [[ANServerManager sharedManager]
     deleteLikeForItemType:@"post"
     forOwnerID:iosDevCourseGroupID
     forItemID:post.postID
     onSuccess:^(NSDictionary* result) {
         NSLog(@"Like deleted successfully!");
         
         NSString* likesCount = [[result objectForKey:@"likes"] stringValue];
         
         post.likes = likesCount;

         post.isLikedByMyself = NO;
         
         [self.tableView reloadData];

     }
     onFailure:^(NSError *error, NSInteger statusCode)
     {
         NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
         
     }];
    
}



#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return [self.postsArray count];
    }
    
    return 1;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    
    static NSString *postIdentifier =       @"postCell";
    static NSString *addPostIdentifier =    @"addPostCell";

    
    if (indexPath.section == ANTableViewSectionAddPost) { // *** ADD POST BUTTON
        
        ANNewPostCell* addPostCell = [tableView dequeueReusableCellWithIdentifier:addPostIdentifier];
        
        
        
        if (!addPostCell) {
            addPostCell = [[ANNewPostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addPostIdentifier];
        }
        
        return addPostCell;
        
    } else if (indexPath.section == ANTableViewSectionWall) { // *** WALL POSTS SECTION
        
        
        ANPostCell* postCell = [tableView dequeueReusableCellWithIdentifier:postIdentifier];
        
        if (!postCell) {
            postCell = [[ANPostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:postIdentifier];
        }
        
        ANPost* post = [self.postsArray objectAtIndex:indexPath.row];
        
        postCell.delegate = self;
        postCell.postID = post.postID;


        if (post.fromGroup != nil) {
            postCell.fullNameLabel.text = post.fromGroup.groupName;
            [postCell.postAuthorImageView setImageWithURL:post.fromGroup.imageURL];
            
            
        } else if (post.author != nil) {
            postCell.fullNameLabel.text = [NSString stringWithFormat:@"%@ %@", post.author.firstName, post.author.lastName];
            [postCell.postAuthorImageView setImageWithURL:post.author.imageURL];
            
        }
        
        // *** CREATING GESTURE RECOGNIZER FOR HADLE AUTHOR IMAGEVIEW TAP
        
        postCell.postAuthorImageView.userInteractionEnabled = YES;
        
        UIGestureRecognizer* tapAuthorImageViewGesutre =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnImageView:)];
        [postCell.postAuthorImageView addGestureRecognizer:tapAuthorImageViewGesutre];
        
        
        postCell.dateLabel.text = post.date;
        
        
        postCell.commentsCountLabel.text = post.comments;
        
        [postCell.commentButton addTarget:self action:@selector(actionCommentPressed:) forControlEvents:UIControlEventTouchUpInside];

        
        
        [postCell.likeButton setTitle:post.likes forState:UIControlStateNormal];

        if (post.isLikedByMyself) {
            [postCell.likeButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [postCell.likeButton setImage:[UIImage imageNamed:@"like_b_16.png"] forState:UIControlStateNormal];
        } else {
            [postCell.likeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [postCell.likeButton setImage:[UIImage imageNamed:@"like_16.png"] forState:UIControlStateNormal];

        }

        
        postCell.postTextLabel.text = post.text;
        
        
        // *** ADDING IMAGES
        // **** IF ONLY ONE PHOTO. PLACING IT TO MAIN IMAGEVIEW
        postCell.postImageView.image = nil;
        
        if (post.postMainImageURL) {
            [postCell.postImageView setImageWithURL:post.postMainImageURL];
        }
        
        // **** IF THERE'RE MANY PHOTOS - PLACE THE FIRST ONE TO THE MAIN IMAGEVIEW, THEN
        // **** TAKE THE FOLLOWING 3, AND FILL GALLERY BY THEM
        postCell.galleryImageViewFirst.image = nil;
        postCell.galleryImageViewSecond.image = nil;
        postCell.galleryImageViewThird.image = nil;
        
        if ([post.attachmentsArray count] > 1) {
            for (int i = 1; i < MIN(4, [post.attachmentsArray count]) ; i++) {
                ANPhoto* photo = [post.attachmentsArray objectAtIndex:i];
                NSURL* photoURL = [NSURL URLWithString:photo.photo_604];
                
                UIImageView* imageView = [postCell.galleryImageViews objectAtIndex:i-1];
                
                [imageView setImageWithURL:photoURL];
                
            }
        }

        
        return postCell;
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

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return NO;
    }
    return YES;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self performTransitionToPostDetails:indexPath];
    
}



#pragma mark - Gestures

- (void) handleTapOnImageView:(UITapGestureRecognizer*) recognizer {
    
    NSLog(@"TAP WORKS!!");
    
    // Taking tapped image view from activated recognizer
    UIImageView* tappedImageView = (UIImageView*)recognizer.view;
    
    // Getting cell that has this image view. Double superview becuase - Cell->ContentView->ImageView
    UITableViewCell* cell = (UITableViewCell*)tappedImageView.superview.superview;
    
    NSIndexPath* clickedIndexPath = [self.tableView indexPathForCell:cell];
    
    ANPost* clickedPost = [self.postsArray objectAtIndex:clickedIndexPath.row];
    
    ANMessagesViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ANMessagesViewController"];
    
    vc.partnerUserID = clickedPost.authorID;
    
    if (clickedPost.author != nil) {
        vc.partnerUser = clickedPost.author;
    } else if (clickedPost.fromGroup != nil) {
        vc.partnerGroup = clickedPost.fromGroup;
    }
    
    
    [self.navigationController pushViewController:vc animated:YES];
    
}




#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= self.tableView.contentSize.height - scrollView.frame.size.height) {
        if (!self.loadingData)
        {
            [self getPostsFromServer];
        }
    }
}


#pragma mark - Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addPostSegue"]) {
        ANAddPostViewController* vc = [segue destinationViewController];
        
        vc.delegate = self;
        
        
    }
}









#pragma mark - +++ ANAddPostDelegate +++

- (void) postDidSend {
    [self refreshWall];
}


#pragma mark - +++ ANPostCellDelegate +++

- (void) likeButtonPressedForPostID:(NSString*) postID {
    
    NSLog(@"Incoming postID = %@", postID);
    ANPost* clickedPost;
    for (ANPost* post in self.postsArray) {
        if ([postID isEqualToString:post.postID]) {
            clickedPost = post;
        }
    }
    
    if (clickedPost.isLikedByMyself) {
        [self deleteLikeForPost:clickedPost];
    } else {
        [self addLikeForPost:clickedPost];
    }
    


}


@end
