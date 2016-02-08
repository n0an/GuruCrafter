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
#import "UIImageView+AFNetworking.h"

#import "ANPost.h"
#import "ANPostCell.h"


@interface ViewController () <UIScrollViewDelegate>

@property (assign, nonatomic) BOOL firstTimeAppear;

@property (strong, nonatomic) NSMutableArray* postsArray;

@property (assign, nonatomic) BOOL loadingData;


@end

static NSInteger postsInRequest = 20;


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.postsArray = [NSMutableArray array];
    
    self.firstTimeAppear = YES;
    
    self.loadingData = YES;

    [self getPostsFromServer];

    
    UIRefreshControl* refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshWall) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    
    UIBarButtonItem* addPostBarButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                  target:self
                                                  action:@selector(postOnWall:)];
    
    self.navigationItem.rightBarButtonItem = addPostBarButton;

    
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










#pragma mark - API


- (void) getPostsFromServer {
    
    
    [[ANServerManager sharedManager] getGroupWall:@"58860049"
                                       withOffset:[self.postsArray count]
                                            count:postsInRequest
                                        onSuccess:^(NSArray *posts) {
                                            [self.postsArray addObjectsFromArray:posts];
                                            
                                            NSMutableArray* newPaths = [NSMutableArray array];
                                            
                                            for (int i = (int)[self.postsArray count] - (int)[posts count]; i < [self.postsArray count]; i++) {
                                                [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                                            }
                                            
                                            [self.tableView beginUpdates];
                                            [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationTop];
                                            [self.tableView endUpdates];
                                            
                                            self.loadingData = NO;


                                        }
                                        onFailure:^(NSError *error, NSInteger statusCode) {
                                            NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);

                                        }];
    
    
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.postsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *postIdentifier = @"postCell";

    ANPostCell* postCell = [tableView dequeueReusableCellWithIdentifier:postIdentifier];
    
    if (!postCell) {
        postCell = [[ANPostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:postIdentifier];
    }
    
    ANPost* post = [self.postsArray objectAtIndex:indexPath.row];
    
    postCell.fullNameLabel.text = [NSString stringWithFormat:@"%@ %@", post.author.firstName, post.author.lastName];
    
    postCell.postTextLabel.text = post.text;
    postCell.dateLabel.text = post.date;
    
    postCell.commentsCountLabel.text = post.comments;
    postCell.likesCountLabel.text = post.likes;
    
    
    [postCell.postAuthorImageView setImageWithURL:post.author.imageURL];
    
    
    postCell.postImageView.image = nil;
    
    [postCell.postImageView setImageWithURL:post.postImageURL];

    /*
    NSURLRequest* request = [NSURLRequest requestWithURL:post.postImageURL];
    
    __weak ANPostCell* weakPostCell = postCell;
    
    [postCell.postImage
     setImageWithURLRequest:request
     placeholderImage:nil
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
         
         weakPostCell.postImage.image = image;
         
     }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         
     }];
     */
    
    
    return postCell;
    
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
            self.loadingData = YES;
            [self getPostsFromServer];
        }
    }
}







@end
