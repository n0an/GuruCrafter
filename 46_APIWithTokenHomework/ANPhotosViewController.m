//
//  ANPhotosViewController.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 21/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANPhotosViewController.h"
#import "ANServerManager.h"
#import "UIImageView+AFNetworking.h"
#import "ANPhotoCollectionViewCell.h"
#import "ANPhoto.h"
#import "ANPhotoAlbum.h"

#import "ANPhotoDetailsViewController.h"
#import "ANUploadServer.h"
#import "ANParsedUploadServer.h"
#import "ANPhotoAddingViewController.h"

#import <UIScrollView+SVInfiniteScrolling.h>
#import <UIScrollView+SVPullToRefresh.h>


@interface ANPhotosViewController () <ANPhotoAddingDelegate, ANPhotoViewerDelegate>
@property (strong, nonatomic) NSMutableArray* photosArray;
@property (assign, nonatomic) BOOL loadingData;

@property (strong, nonatomic) NSMutableArray* allPhotosInAlbumArray;


@property (strong, nonatomic) ANPhoto* currentViewingPhoto;

@end

static NSInteger requestCount = 20;
static NSString* iosDevCourseGroupID = @"58860049";
static NSString* myVKAccountID = @"21743772";

@implementation ANPhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.allPhotosInAlbumArray = [NSMutableArray array];
    self.photosArray = [NSMutableArray array];
    self.loadingData = YES;
    [self getPhotosFromServer];

    [self infiniteScrolling];

    

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Helper Methods


- (void)infiniteScrolling {
    
    __weak ANPhotosViewController* weakSelf = self;
    
    [self.collectionView addPullToRefreshWithActionHandler:^{
        
        [weakSelf refreshPhotos];
        
        // once refresh, allow the infinite scroll again
        weakSelf.collectionView.showsInfiniteScrolling = YES;
    }];
    
    
    [self.collectionView addInfiniteScrollingWithActionHandler:^{
        
        [weakSelf getPhotosFromServer];
        
    }];
}





#pragma mark - API

- (void) getPhotosFromServer {
    
    [[ANServerManager sharedManager] getPhotosForGroup:iosDevCourseGroupID
            forAlbumID:self.album.albumID
            withOffset:[self.photosArray count]
                 count:requestCount
             onSuccess:^(NSArray *photos) {
                 
                 if ([photos count] > 0) {
                     
                     [self.photosArray addObjectsFromArray:photos];
                     
                     NSMutableArray *newPaths = [NSMutableArray array];
                     
                     for (int i = (int)[self.photosArray count] - (int)[photos count]; i < [self.photosArray count]; i++) {
                         
                         [newPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
                     }
                     
                     [self.collectionView insertItemsAtIndexPaths:newPaths];
                     
                 }
                 
                 self.loadingData = NO;
                 [self.collectionView.infiniteScrollingView stopAnimating];

                 
                 
             }
             onFailure:^(NSError *error, NSInteger statusCode) {
                 NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
                 self.collectionView.showsInfiniteScrolling = NO;
                 [self.collectionView.infiniteScrollingView stopAnimating];
             }];
    
}



- (void) refreshPhotos {
    
    if (self.loadingData == NO) {
        self.loadingData = YES;
        
        
        [[ANServerManager sharedManager] getPhotosForGroup:iosDevCourseGroupID
                forAlbumID:self.album.albumID
                withOffset:0
                     count:MAX(requestCount, [self.photosArray count])
                 onSuccess:^(NSArray *photos) {
                     
                     if ([photos count] > 0) {
                         [self.photosArray removeAllObjects];
                         [self.photosArray addObjectsFromArray:photos];
                         
                         [self.collectionView reloadData];
                     }
                     
                     self.loadingData = NO;

                     [self.collectionView.pullToRefreshView stopAnimating];

                     
                     
                 }
                 onFailure:^(NSError *error, NSInteger statusCode) {
                     NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);

                     [self.collectionView.pullToRefreshView stopAnimating];

                     

                 }];
        
    }
    
    
}




- (void) getAllPhotosFromServer {
    
    [[ANServerManager sharedManager] getPhotosForGroup:iosDevCourseGroupID
            forAlbumID:self.album.albumID
            withOffset:[self.photosArray count]
                 count:[self.album.albumSize integerValue] - [self.photosArray count]
             onSuccess:^(NSArray *photos) {
                 
                 if ([photos count] > 0) {
                     [self.allPhotosInAlbumArray addObjectsFromArray:photos];

                 }
                 
                 
             }
             onFailure:^(NSError *error, NSInteger statusCode) {
                 NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
             }];
    
}





#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.photosArray count];
}




- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* photoIdentifier = @"photoCVCell";
    
    ANPhotoCollectionViewCell* photoCVCell = [collectionView dequeueReusableCellWithReuseIdentifier:photoIdentifier forIndexPath:indexPath];
    
    ANPhoto* photo = [self.photosArray objectAtIndex:indexPath.row];
    
    NSURL* photoURL = [NSURL URLWithString:photo.photo_130];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:photoURL];
    
    __weak ANPhotoCollectionViewCell* weakPhotoCVCell = photoCVCell;
    
    photoCVCell.photoImageView.image = nil;
    
    [photoCVCell.photoImageView
     setImageWithURLRequest:request
     placeholderImage:nil
     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
         
         [UIView transitionWithView:weakPhotoCVCell.photoImageView
                           duration:0.3f
                            options:UIViewAnimationOptionTransitionCrossDissolve
                         animations:^{
                             weakPhotoCVCell.photoImageView.image = image;
                         } completion:nil];
         
     }
     failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
         
     }];
    
    
    
    
    
    return photoCVCell;
}



#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
 
    ANPhoto* selectedPhoto = [self.photosArray objectAtIndex:indexPath.row];
    
    self.currentViewingPhoto = selectedPhoto;
    
    ANPhotoDetailsViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ANPhotoDetailsViewController"];
    vc.photo = selectedPhoto;
    vc.delegate = self;
    
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nav animated:YES completion:nil];
    
    [self.allPhotosInAlbumArray addObjectsFromArray:self.photosArray];

    [self getAllPhotosFromServer];
    
    
    
}




#pragma mark - Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addNewPhoto"]) {
        
        ANPhotoAddingViewController* vc = segue.destinationViewController;
        
        vc.albumID = self.album.albumID;
        vc.delegate = self;
        
    }
}


#pragma mark - +++ ANPhotoAddingDelegate +++

- (void) photoDidFinishUploading {

    [self refreshPhotos];
}

#pragma mark - +++ ANPhotoViewerDelegate +++

- (ANPhoto*) iteratePhoto:(ANPhotoIterationDirection) iterationDirection {
    
    ANPhoto* iteratedPhoto;
    
    NSInteger currentViewingPhotoIndex = [self.allPhotosInAlbumArray indexOfObject:self.currentViewingPhoto];
    NSInteger iteratedPhotoIndex;
    
    if (iterationDirection == ANPhotoIterationDirectionNext) {
        
        NSLog(@"iteratePhoto Next");
        
        if ([self.currentViewingPhoto isEqual:[self.allPhotosInAlbumArray lastObject]]) {
            iteratedPhoto = [self.allPhotosInAlbumArray firstObject];
            
        } else {
            
            iteratedPhotoIndex = currentViewingPhotoIndex + 1;
            
            iteratedPhoto = [self.allPhotosInAlbumArray objectAtIndex:iteratedPhotoIndex];
        }
        
    } else {
        
        NSLog(@"iteratePhoto Previous");

        if ([self.currentViewingPhoto isEqual:[self.allPhotosInAlbumArray firstObject]]) {
            iteratedPhoto = [self.allPhotosInAlbumArray lastObject];
            
        } else {
            
            iteratedPhotoIndex = currentViewingPhotoIndex - 1;
            
            iteratedPhoto = [self.allPhotosInAlbumArray objectAtIndex:iteratedPhotoIndex];

        }
        
    }
    
    self.currentViewingPhoto = iteratedPhoto;
    
    return iteratedPhoto;
    
}




@end
