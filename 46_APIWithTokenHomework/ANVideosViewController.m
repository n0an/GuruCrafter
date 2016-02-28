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
#import "ANVideoPlayerViewController.h"

@interface ANVideosViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) NSMutableArray* videosArray;
@property (assign, nonatomic) BOOL loadingData;
@property (strong, nonatomic) UIRefreshControl* refreshControl;

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
    
    UIRefreshControl* refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshVideos) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:refresh];
    self.refreshControl = refresh;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                             [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationFade];
                             [self.tableView endUpdates];
                             
                         });
                         
                     });
                 }
                 
                 self.loadingData = NO;

             }
     
             onFailure:^(NSError *error, NSInteger statusCode) {
                 
                 NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
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
                 [self.refreshControl endRefreshing];
                 self.loadingData = NO;
             }
             onFailure:^(NSError *error, NSInteger statusCode) {
                 NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
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


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= self.tableView.contentSize.height - scrollView.frame.size.height) {
        if (!self.loadingData)
        {
            [self getVideosFromServer];
        }
    }
}


#pragma mark - Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showVideo"]) {
        
        NSIndexPath* selectedIndexPath = [self.tableView indexPathForSelectedRow];
        
        ANVideo* selectedVideo = [self.videosArray objectAtIndex:selectedIndexPath.row];
        
//        NSURL* videoURL = [NSURL URLWithString:selectedVideo.videoPlayerURLString];
        

        UINavigationController* nav = segue.destinationViewController;
        
        ANVideoPlayerViewController* vc = (ANVideoPlayerViewController*)nav.topViewController;
        
//        vc.videoURL = videoURL;
        vc.selectedVideo = selectedVideo;
        
        
 
    }
}


@end








