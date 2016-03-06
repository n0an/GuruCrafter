//
//  ANVideosViewController.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 23/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANVideosViewController.h"
#import "ANServerManager.h"
#import "ANVideoAlbum.h"
#import "ANVideo.h"
#import "UIImageView+AFNetworking.h"

#import "ANVideoCell.h"
#import "ANVideoPlayerVC.h"

#import <UIScrollView+SVInfiniteScrolling.h>
#import <UIScrollView+SVPullToRefresh.h>

@interface ANVideosViewController ()

@property (strong, nonatomic) NSMutableArray* videosArray;
@property (assign, nonatomic) BOOL loadingData;


@end

static NSInteger requestCount = 20;
static NSString* iosDevCourseGroupID = @"58860049";
static NSString* myVKAccountID = @"21743772";


@implementation ANVideosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.videosArray = [NSMutableArray array];
    self.loadingData = YES;
    [self getVideosFromServer];
    
    [self infiniteScrolling];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Helper Methods


- (void)infiniteScrolling {
    
    __weak ANVideosViewController* weakSelf = self;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        
        [weakSelf refreshVideos];
        
        // once refresh, allow the infinite scroll again
        weakSelf.tableView.showsInfiniteScrolling = YES;
    }];
    
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        
        [weakSelf getVideosFromServer];
        
    }];
}




#pragma mark - API

- (void) getVideosFromServer {
    
    [[ANServerManager sharedManager] getVideosForGroup:iosDevCourseGroupID
            forAlbumID:self.videoAlbum.albumID
            withOffset:[self.videosArray count]
                 count:requestCount
             onSuccess:^(NSArray *videos) {
                 
                 if ([videos count] > 0) {
                     
                     dispatch_queue_t highQueue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0);
                     
                     dispatch_async(highQueue, ^{
                         [self.videosArray addObjectsFromArray:videos];
                         
                         NSMutableArray* newPaths = [NSMutableArray array];
                         
                         for (int i = (int)[self.videosArray count] - (int)[videos count]; i < [self.videosArray count]; i++) {
                             [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                         }
                         
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [self.tableView beginUpdates];
                             [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationRight];
                             [self.tableView endUpdates];
                             
                         });
                         
                     });
                 }
                 
                 self.loadingData = NO;
                 [self.tableView.infiniteScrollingView stopAnimating];


             }
     
             onFailure:^(NSError *error, NSInteger statusCode) {
                 
                 NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
                 self.tableView.showsInfiniteScrolling = NO;
                 [self.tableView.infiniteScrollingView stopAnimating];

             }];
    
    
}


- (void) refreshVideos {
    
    if (self.loadingData == NO) {
        self.loadingData = YES;
        
        [[ANServerManager sharedManager] getVideosForGroup:iosDevCourseGroupID
            forAlbumID:self.videoAlbum.albumID
            withOffset:0
                 count:MAX(requestCount, [self.videosArray count])
             onSuccess:^(NSArray *videos) {
                 
                 
                 if ([videos count] > 0) {
                     [self.videosArray removeAllObjects];
                     [self.videosArray addObjectsFromArray:videos];
                     
                     [self.tableView reloadData];
                     
                 }

                 self.loadingData = NO;
                 [self.tableView.pullToRefreshView stopAnimating];

             }
             onFailure:^(NSError *error, NSInteger statusCode) {
                 NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);

                 [self.tableView.pullToRefreshView stopAnimating];


             }];
   
    }
    
    
}



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.videosArray count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* videoIdentifier = @"videoCell";
    
    ANVideoCell* videoCell = [tableView dequeueReusableCellWithIdentifier:videoIdentifier];
    
    if (!videoCell) {
        videoCell = [[ANVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:videoIdentifier];
    }
    
    ANVideo* video = [self.videosArray objectAtIndex:indexPath.row];
    
    videoCell.titleLabel.text = video.title;
    videoCell.durationLabel.text = [NSString stringWithFormat:@"  %@  ", video.duration];
    
    videoCell.viewsCountLabel.text = [NSString stringWithFormat:@"%@ views", video.views];
    videoCell.dateLabel.text = [NSString stringWithFormat:@"Added on: %@", video.date];
    

    
    NSURLRequest* videoThumbRequest = [NSURLRequest requestWithURL:video.videoThumbImageURL];
    
    __block UIImageView* weakVideoThumbImageView = videoCell.videoThumbImageVIew;
    
    [videoCell.videoThumbImageVIew
     setImageWithURLRequest:videoThumbRequest
     placeholderImage:nil
     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
         
         
         [UIView transitionWithView:weakVideoThumbImageView
                           duration:0.3f
                            options:UIViewAnimationOptionTransitionCrossDissolve
                         animations:^{
                             weakVideoThumbImageView.image = image;
                         }
                         completion:nil];
         
         
     }
     failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
         
     }];

    return videoCell;
    

}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 115;
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    return 115;
    
}




#pragma mark - Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showVideo"]) {
        
        NSIndexPath* selectedIndexPath = [self.tableView indexPathForSelectedRow];
        
        ANVideo* selectedVideo = [self.videosArray objectAtIndex:selectedIndexPath.row];
    
        UINavigationController* nav = segue.destinationViewController;
        
        ANVideoPlayerVC* vc = (ANVideoPlayerVC*)nav.topViewController;
        
        vc.selectedVideo = selectedVideo;
        
 
    }
}


@end








