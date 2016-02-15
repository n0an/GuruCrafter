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


@interface ViewController () <UIScrollViewDelegate, ANAddPostDelegate>

@property (assign, nonatomic) BOOL firstTimeAppear;

@property (strong, nonatomic) NSMutableArray* postsArray;

@property (assign, nonatomic) BOOL loadingData;


@property (strong,nonatomic) NSMutableArray *postImageViewsSizesArray;


@end

static NSInteger postsInRequest = 20;


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.postsArray = [NSMutableArray array];
    self.postImageViewsSizesArray = [NSMutableArray array];
    self.firstTimeAppear = YES;
    
    self.loadingData = YES;

    [self getPostsFromServer];

    
    UIRefreshControl* refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshWall) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.firstTimeAppear) {
        
        self.firstTimeAppear = NO;
        
        [[ANServerManager sharedManager] authorizeUser:^(ANUser *user) {
            NSLog(@"AUTHORIZED!");
            NSLog(@"%@ %@", user.firstName, user.lastName);
            
            ANServerManager* serverManager = [ANServerManager sharedManager];
            serverManager.currentUser = user;
//            serverManager.photoSelfURL = user.imageURL;
        }];
    }
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - API


- (void) getPostsFromServer {
    
    [[ANServerManager sharedManager]
     getGroupWall:@"58860049"
     withOffset:[self.postsArray count]
     count:postsInRequest
     onSuccess:^(NSArray *posts) {
         
         [self.postsArray addObjectsFromArray:posts];
         
         NSMutableArray* newPaths = [NSMutableArray array];
         
         for (int i = (int)[self.postsArray count] - (int)[posts count]; i < [self.postsArray count]; i++) {
             [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:1]];
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


- (void) refreshWall {
    
    self.loadingData = YES;
    
    [[ANServerManager sharedManager]
     getGroupWall:@"58860049"
     withOffset:0
     count:MAX(postsInRequest, [self.postsArray count])
     onSuccess:^(NSArray *posts) {
         
         [self.postsArray removeAllObjects];
         
         [self.postsArray addObjectsFromArray:posts];
         
         [self.tableView reloadData];
         
         [self.refreshControl endRefreshing];
         
         self.loadingData = NO;

     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         
         NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
         
         [self.refreshControl endRefreshing];
         
     }];
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

    
    if (indexPath.section == 0) { // *** ADD POST BUTTON
        
        ANNewPostCell* addPostCell = [tableView dequeueReusableCellWithIdentifier:addPostIdentifier];
        
        
        
        if (!addPostCell) {
            addPostCell = [[ANNewPostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addPostIdentifier];
        }
        
        return addPostCell;
        
    } else if (indexPath.section == 1) { // *** WALL POSTS SECTION
        
        
        ANPostCell* postCell = [tableView dequeueReusableCellWithIdentifier:postIdentifier];
        
        if (!postCell) {
            postCell = [[ANPostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:postIdentifier];
        }
        
        ANPost* post = [self.postsArray objectAtIndex:indexPath.row];


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
        postCell.likesCountLabel.text = post.likes;
        
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
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



@end
