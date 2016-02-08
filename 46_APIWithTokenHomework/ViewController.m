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

static CGSize CGSizeResizeToHeight(CGSize size, CGFloat height) {
    size.width *= height / size.height;
    size.height = height;
    return size;
}

@interface ViewController () <UIScrollViewDelegate>

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
    
    self.loadingData = NO;

    [self getPostsFromServer];

    
    UIRefreshControl* refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshWall) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    
//    UIBarButtonItem* addPostBarButton =
//    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
//                                                  target:self
//                                                  action:@selector(postOnWall:)];
//    
//    self.navigationItem.rightBarButtonItem = addPostBarButton;

    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.firstTimeAppear) {
        
        self.firstTimeAppear = NO;
        
        [[ANServerManager sharedManager] authorizeUser:^(ANUser *user) {
            NSLog(@"AUTHORIZED!");
            NSLog(@"%@ %@", user.firstName, user.lastName);
        }];
    }
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Helper Methods




#pragma mark - API


- (void) getPostsFromServer {
    
    if (!self.loadingData) {
        self.loadingData = YES;
        
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
    
    
    
    
}


- (void) refreshWall {
    
    [[ANServerManager sharedManager]
     getGroupWall:@"58860049"
     withOffset:0
     count:MAX(postsInRequest, [self.postsArray count])
     onSuccess:^(NSArray *posts) {
         
         [self.postsArray removeAllObjects];
         
         [self.postsArray addObjectsFromArray:posts];
         
         [self.tableView reloadData];
         
         [self.refreshControl endRefreshing];
         
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         
         NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
         
         [self.refreshControl endRefreshing];
         
     }];
    
    
}


- (void) postOnWall:(id) sender {
    
    [[ANServerManager sharedManager]
     postText:@"Test from 47 Lesson :-)"
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
        
        UITableViewCell* addPostCell = [tableView dequeueReusableCellWithIdentifier:addPostIdentifier];
        
        if (!addPostCell) {
            addPostCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addPostIdentifier];
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
        
        postCell.dateLabel.text = post.date;
        
        postCell.commentsCountLabel.text = post.comments;
        postCell.likesCountLabel.text = post.likes;
        
        
        postCell.postTextLabel.text = post.text;
        
        
        
        
        // *** ADDING IMAGES
        
        
        
        
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





#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
        if (!self.loadingData)
        {
//            self.loadingData = YES;
            [self getPostsFromServer];
        }
    }
}







@end
