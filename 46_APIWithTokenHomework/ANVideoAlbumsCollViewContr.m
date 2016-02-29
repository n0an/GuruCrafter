//
//  ANVideoAlbumsCollViewContr.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 22/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANVideoAlbumsCollViewContr.h"
#import "ANServerManager.h"
#import "ANVideoAlbum.h"
#import "ANVideoAlbumCVCell.h"
#import "UIImageView+AFNetworking.h"

#import "ANVideosViewController.h"

#import <SWRevealViewController.h>


@interface ANVideoAlbumsCollViewContr () <UIScrollViewDelegate>

@property (strong, nonatomic) NSMutableArray* videoAlbumsArray;
@property (assign, nonatomic) BOOL loadingData;

@property (strong, nonatomic) UIRefreshControl* refreshControl;

@end


static NSInteger requestCount = 20;
static NSString* iosDevCourseGroupID = @"58860049";
static NSString* myVKAccountID = @"21743772";


@implementation ANVideoAlbumsCollViewContr

static NSString * const reuseIdentifier = @"videoCVCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.menuRevealBarButton setTarget: self.revealViewController];
        [self.menuRevealBarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }

    
    self.videoAlbumsArray = [NSMutableArray array];
    self.loadingData = YES;
    
    
    [self getAlbumsFromServer];
    
    UIRefreshControl* refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshAlbums) forControlEvents:UIControlEventValueChanged];
    
    [self.collectionView addSubview:refresh];
    
    self.refreshControl = refresh;

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (void) actionCellTapped:(UITapGestureRecognizer*) recognizer {
    
    
    NSLog(@"TAP WORKS!!");
    
    ANVideoAlbumCVCell* clickedCell = (ANVideoAlbumCVCell*)recognizer.view;
    
    NSIndexPath* clickedIndexPath = [self.collectionView indexPathForCell:clickedCell];
    
    ANVideoAlbum* clickedAlbum = [self.videoAlbumsArray objectAtIndex:clickedIndexPath.row];
    
    ANVideosViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ANVideosViewController"];
    
    vc.videoAlbum = clickedAlbum;
    
    [self.navigationController pushViewController:vc animated:YES];
    
    
}


#pragma mark - API

- (void) getAlbumsFromServer {
    
    [[ANServerManager sharedManager] getVideoAlbumsForGroupID:iosDevCourseGroupID
               withOffset:[self.videoAlbumsArray count]
                    count:requestCount
                onSuccess:^(NSArray *videoAlbums) {
                    
                    NSLog(@"videoAlbums = %@", videoAlbums);
                    
                    if ([videoAlbums count] > 0) {
                        [self.videoAlbumsArray addObjectsFromArray:videoAlbums];
                        
                        NSMutableArray *newPaths = [NSMutableArray array];
                        
                        for (int i = (int)[self.videoAlbumsArray count] - (int)[videoAlbums count]; i < [self.videoAlbumsArray count]; i++) {
                            
                            [newPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
                        }
                        
                        [self.collectionView insertItemsAtIndexPaths:newPaths];
                        
                        // [self.collectionView reloadData];

                    }
                    
                    self.loadingData = NO;
                    
                }

                onFailure:^(NSError *error, NSInteger statusCode) {
                    NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
                }];

    
}

- (void) refreshAlbums {
    
    if (self.loadingData == NO) {
        self.loadingData = YES;
        
        [[ANServerManager sharedManager] getVideoAlbumsForGroupID:iosDevCourseGroupID
               withOffset:0
                    count:MAX(requestCount, [self.videoAlbumsArray count])
                onSuccess:^(NSArray *videoAlbums) {
                    
                    NSLog(@"videoAlbums = %@", videoAlbums);
                    
                    if ([videoAlbums count] > 0) {
                        
                        [self.videoAlbumsArray removeAllObjects];
                        
                        [self.videoAlbumsArray addObjectsFromArray:videoAlbums];
                        
                        [self.collectionView reloadData];
                   
                    }
                    
                    [self.refreshControl endRefreshing];
                    
                    self.loadingData = NO;
                    
                }

                onFailure:^(NSError *error, NSInteger statusCode) {
                    NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
                    [self.refreshControl endRefreshing];
                }];

        
    }
    
    
    
}





#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.videoAlbumsArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ANVideoAlbumCVCell *videoAlbumCell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    ANVideoAlbum* videoAlbum = [self.videoAlbumsArray objectAtIndex:indexPath.row];
    
    videoAlbumCell.titleLabel.text = videoAlbum.albumTitle;
    videoAlbumCell.sizeLabel.text = [NSString stringWithFormat:@"%@ videos", videoAlbum.albumSize];
    videoAlbumCell.dateLabel.text = [NSString stringWithFormat:@"Updated on %@", videoAlbum.date];

    
    NSURLRequest* albumThumbRequest = [NSURLRequest requestWithURL:videoAlbum.albumThumbImageURL];
    
    __block UIImageView* weakAlbumImageView = videoAlbumCell.albumImageView;
    
    [videoAlbumCell.albumImageView
     setImageWithURLRequest:albumThumbRequest
     placeholderImage:nil
     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
         
         
         [UIView transitionWithView:weakAlbumImageView
                           duration:0.3f
                            options:UIViewAnimationOptionTransitionCrossDissolve
                         animations:^{
                             weakAlbumImageView.image = image;
                         }
                         completion:nil];
         
         
     }
     failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
         
     }];
    
    

    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionCellTapped:)];
    
    [videoAlbumCell addGestureRecognizer:tapGesture];
    
    
    return videoAlbumCell;
}

#pragma mark - UICollectionViewDelegate


// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"shouldHighlightItemAtIndexPath");
	return YES;
}


// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"shouldSelectItemAtIndexPath");
    return YES;
}




#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
        NSLog(@"scrollViewDidScroll");
        if (!self.loadingData)
        {
            self.loadingData = YES;
            [self getAlbumsFromServer];
        }
    }
}







@end
