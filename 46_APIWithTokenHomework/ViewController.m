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

#import <SWRevealViewController.h>


typedef enum {
    ANTableViewSectionAddPost,
    ANTableViewSectionWall,
    
} ANTableViewSection;



@interface ViewController () <UIScrollViewDelegate, ANAddPostDelegate, ANPostCellDelegate>

@property (strong, nonatomic) NSMutableArray* postsArray;

@property (assign, nonatomic) BOOL loadingData;
@property (assign, nonatomic) BOOL isLikedPost;

@end

static NSInteger postsInRequest = 20;
static NSString* iosDevCourseGroupID = @"58860049";
static NSString* myVKAccountID = @"21743772";

static NSInteger firstRowCount = 3;


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.menuRevealBarButton setTarget: self.revealViewController];
        [self.menuRevealBarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    self.postsArray = [NSMutableArray array];

    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    UIRefreshControl* refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshWall) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    ANUser* loginedUser = [[ANServerManager sharedManager] currentUser];
    
    NSLog(@"%@ %@", loginedUser.firstName, loginedUser.lastName);
    
    self.loadingData = YES;

    [self getPostsFromServer];
       
    
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




#pragma mark - API


- (void) getPostsFromServer {
    
    [[ANServerManager sharedManager]
     getGroupWall:@"58860049"
     withOffset:[self.postsArray count]
     count:postsInRequest
     onSuccess:^(NSArray *posts) {
         
         if ([posts count] > 0) {
             
             dispatch_queue_t highQueue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0);
             
             dispatch_async(highQueue, ^{
                 [self.postsArray addObjectsFromArray:posts];
                 
                 NSMutableArray* newPaths = [NSMutableArray array];
                 
                 for (int i = (int)[self.postsArray count] - (int)[posts count]; i < [self.postsArray count]; i++) {
                     [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:1]];
                 }
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
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
        
        /**********************
         * SHOW IMAGES IN POST
         **********************
         */
        
        
            /*-- PART 1. CHECKINGS --
             */
                //  If post contains no photos - set all ImageViews height to 0 (collapsing all Gallery ImageViews), and return cell immediately
        if ([post.attachmentsArray count] == 0) {
            postCell.gallerySecondRowTopConstraint.constant = 0;
            
            for (NSLayoutConstraint* heightOfImageView in postCell.photoHeights) {
                heightOfImageView.constant = 0;
            }
            
            return postCell;
        }
        
        
                //  Check of attachments array before start main loop. If occasionally, there's photo with width or height equals to 0 - remove this photo from attachments array
        for (int i = 0; i < [post.attachmentsArray count]; ) {
            ANPhoto* photo = [post.attachmentsArray objectAtIndex:i];
            if (photo.width == 0 || photo.height == 0){
                NSMutableArray* tmpArray = [NSMutableArray arrayWithArray:post.attachmentsArray];
                [tmpArray removeObject:photo];
                post.attachmentsArray = tmpArray;
                continue;
            }
            i++;
        }

        
        
            /*-- PART 2. CALCULATIONS OF MAXIMUM SIZES FOR SQUARE GALLERY IMAGEVIEWS --
             */

                //  Calculation of Gallery ImageViews Maximum Sizes (depending on count of photos)
                //TODO: use Portrait Landscape idioms instead fixing to 400
                //TODO: limit sized in both rows
        CGFloat maxRequiredSizeOfImageInFirstRow = 0;
        CGFloat maxRequiredSizeOfImageInSecondRow = 0;
        
        if ([post.attachmentsArray count] <= firstRowCount) { // If we have 3 or less photos - use only ONE row of Gallery
            
            NSLog(@"self.tableView.frame width = %f", self.tableView.frame.size.width);
            
            maxRequiredSizeOfImageInFirstRow = (CGRectGetWidth(self.tableView.frame) - 16 - 4 * ([post.attachmentsArray count] - 1))/ [post.attachmentsArray count];
            
            maxRequiredSizeOfImageInFirstRow = MIN(maxRequiredSizeOfImageInFirstRow, 400); // Limit to 400 even in landscape mode of iphone
   
        } else { //** If we have more than 3 photos - use TWO rows of Gallery
            
            maxRequiredSizeOfImageInFirstRow = (CGRectGetWidth(self.tableView.frame) - 16 - 4 * (firstRowCount - 1)) / 3;
            
            maxRequiredSizeOfImageInSecondRow =
            (CGRectGetWidth(self.tableView.frame) - 16 - 4 * ([post.attachmentsArray count] - firstRowCount - 1)) / ([post.attachmentsArray count] - firstRowCount);
            
            maxRequiredSizeOfImageInSecondRow = MIN(maxRequiredSizeOfImageInSecondRow, 400); // Limit to 400 even in landscape mode of iphone

        }

        
        
            /*-- PART 3. LOOP THROUGH PHOTOS IN ATTACHMENTS ARRAY AND HANDLE EACH PHOTO --
             */
        
        UIImage* placeHolderImage = [[UIImage alloc] init];
        
        CGFloat maxHeigthFirstRow = 0;
        CGFloat fullWidthFirstRow = 0;
        CGFloat fullWidthSecondRow = 0;
        
        // *********^^^^^^^ MAIN LOOP FOR STARTS HERE ^^^^^^^****************
        for (int i = 0; i < ([post.attachmentsArray count]) && (i < firstRowCount * 2); i++) {
            
            ANPhoto* photo = [post.attachmentsArray objectAtIndex:i];
            
            // * 1. Calculating width and height of current photo, according to calculated maxSize of square ImageView. If there's portrait photo - currentHeight = maxSize, if album oriented - currentWidth = maxSize
            
            CGFloat ratio = (CGFloat)photo.width / photo.height;
            
            CGFloat heightOfCurrentPhoto;
            CGFloat widthOfCurrentPhoto;
            
            if (ratio < 1) { // ** Portrait oriented photo
                
                if (i < firstRowCount) { // *** First Row of Gallery
                    
                    heightOfCurrentPhoto = maxRequiredSizeOfImageInFirstRow;
                    
                    widthOfCurrentPhoto = heightOfCurrentPhoto * ratio;
                    fullWidthFirstRow += widthOfCurrentPhoto;
                    
                } else { // *** Second Row of Gallery
                    
                    heightOfCurrentPhoto = maxRequiredSizeOfImageInSecondRow;
                    
                    widthOfCurrentPhoto = heightOfCurrentPhoto * ratio;
                    fullWidthSecondRow += widthOfCurrentPhoto;
                }
                
                
            } else { // ** Landscape oriented photo
                
                if (i < firstRowCount) { // *** First Row of Gallery
                    
                    widthOfCurrentPhoto = maxRequiredSizeOfImageInFirstRow;
                    fullWidthFirstRow += widthOfCurrentPhoto;
                    
                } else { // *** Second Row of Gallery
                    
                    widthOfCurrentPhoto = maxRequiredSizeOfImageInSecondRow;
                    fullWidthSecondRow += widthOfCurrentPhoto;
                    
                }
                
                heightOfCurrentPhoto = widthOfCurrentPhoto / ratio;
            }
            
            
            // * 2. Calculating height of FirstRow to get know value for gallerySecondRowTopConstraint
            if (heightOfCurrentPhoto > maxHeigthFirstRow && i < firstRowCount) {
                maxHeigthFirstRow = heightOfCurrentPhoto;
            }
            
            // * 3. Setting width and height constraints for current photo and setting frame
            NSLayoutConstraint* photoHightConstraint = [postCell.photoHeights objectAtIndex:i];
            photoHightConstraint.constant = heightOfCurrentPhoto;
            
            NSLayoutConstraint* photoWidthConstraint = [postCell.photoWidths objectAtIndex:i];
            photoWidthConstraint.constant = widthOfCurrentPhoto;
            
            
            UIImageView* currentImageView = [postCell.glryImageViews objectAtIndex:i];
            
            CGPoint currentImageViewOrigin = currentImageView.frame.origin;
            
            currentImageView.frame = CGRectMake(currentImageViewOrigin.x,
                                                currentImageViewOrigin.y,
                                                widthOfCurrentPhoto, heightOfCurrentPhoto);
            
            // * 4. Loading and setting image
            NSURL* urlPhoto = [NSURL URLWithString:photo.photo_604];
            
            NSURLRequest* photoRequest = [NSURLRequest requestWithURL:urlPhoto];
            
            __block UIImageView* weakCurrentImageView = currentImageView;
            
            [currentImageView setImageWithURLRequest:photoRequest
                                    placeholderImage:placeHolderImage
                                             success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                                 
                                                 [weakCurrentImageView setImage:image];
                                                 
                                             }
             
                                             failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                                 NSLog(@"%@", [error localizedDescription]);
                                             }];
        }
        
        // *********$$$$$$$$ MAIN LOOP FOR ENDS HERE $$$$$$$****************
        
        
            /*-- PART 4. LAST PREPARATIONS, SETTING GLOBAL GALLERY INSETS, COLLAPSING UNUSED IMAGEVIEWS --
             */
        
                //  Setting top constraint for second row
        postCell.gallerySecondRowTopConstraint.constant = maxHeigthFirstRow + 12.f; // 12 = 8 + 4 - indents (see main.storyboard)
        
                //  For unused Gallery Image Views - setting widhts and heights to 0. Collapsing unused imageviews.
        for (int i = (int)[post.attachmentsArray count]; i < [postCell.photoWidths count]; i++) {
            
            NSLayoutConstraint* photoHightConstraint = [postCell.photoHeights objectAtIndex:i];
            photoHightConstraint.constant = 0.f;
            
            NSLayoutConstraint* photoWidthConstraint = [postCell.photoWidths objectAtIndex:i];
            photoWidthConstraint.constant = 0.f;
            
            UIImageView* unusedImageView = [postCell.glryImageViews objectAtIndex:i];
            
            unusedImageView.frame = CGRectMake(CGRectGetMinX(unusedImageView.frame),
                                                CGRectGetMinY(unusedImageView.frame),
                                                0.f, 0.f);
        }
        
                //  Centering Gallery
        
        CGFloat indentsCountFirstRow, indentsCountSecondRow;
        
        if ([post.attachmentsArray count] <= firstRowCount) {
            
            indentsCountFirstRow = [post.attachmentsArray count] - 1;
            
            postCell.gallerySecondRowLeadingConstraint.constant = 0;
            
        } else {
            
            indentsCountFirstRow = firstRowCount - 1;
            indentsCountSecondRow = [post.attachmentsArray count] - firstRowCount - 1;
            
            postCell.gallerySecondRowLeadingConstraint.constant = (CGRectGetWidth(tableView.frame) - 4 * indentsCountSecondRow - fullWidthSecondRow) / 2;
            
        }
        
        postCell.galleryFirstRowLeadingConstraint.constant = (CGRectGetWidth(tableView.frame) - 4 * indentsCountFirstRow - fullWidthFirstRow) / 2;
        
        
        
        [postCell layoutIfNeeded];

        /*
         ****************************************
         *      END OF SHOW IMAGES IN POST      *
         ****************************************
         */
        
        
        
        
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
            self.loadingData = YES;
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
