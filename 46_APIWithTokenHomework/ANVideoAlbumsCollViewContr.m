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


@interface ANVideoAlbumsCollViewContr ()

@property (strong, nonatomic) NSMutableArray* videoAlbumsArray;
@property (assign, nonatomic) BOOL loadingData;

@end


static NSInteger requestCount = 20;
static NSString* iosDevCourseGroupID = @"58860049";
static NSString* myVKAccountID = @"21743772";


@implementation ANVideoAlbumsCollViewContr

static NSString * const reuseIdentifier = @"videoCVCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.videoAlbumsArray = [NSMutableArray array];
    self.loadingData = YES;
    
    
    [self getAlbumsFromServer];
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
                        
                        [self.collectionView reloadData];
                    }
                    
                    self.loadingData = NO;
                    
                }

                onFailure:^(NSError *error, NSInteger statusCode) {
                    
                }];

    
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

    [videoAlbumCell.albumImageView setImageWithURL:videoAlbum.albumThumbImageURL];
    
//    videoAlbumCell.albumImageView.userInteractionEnabled = YES;
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




@end
