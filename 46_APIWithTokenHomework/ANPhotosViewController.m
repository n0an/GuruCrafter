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

#import "ANPhotoDetailsViewController.h"
#import "ANUploadServer.h"
#import "ANParsedUploadServer.h"
#import "ANPhotoAddingViewController.h"


@interface ANPhotosViewController () <UIScrollViewDelegate, ANPhotoAddingDelegate, ANPhotoViewerDelegate>
@property (strong, nonatomic) NSMutableArray* photosArray;
@property (assign, nonatomic) BOOL loadingData;

@property (strong, nonatomic) UIRefreshControl* refreshControl;

@property (strong, nonatomic) ANPhoto* currentViewingPhoto;

@end

static NSInteger requestCount = 20;
static NSString* iosDevCourseGroupID = @"58860049";
static NSString* myVKAccountID = @"21743772";

@implementation ANPhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.photosArray = [NSMutableArray array];
    
    self.loadingData = YES;
    
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshPhotos) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshControl];
    
    self.refreshControl = refreshControl;
    
    [self getPhotosFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - API

- (void) getPhotosFromServer {
    
    [[ANServerManager sharedManager] getPhotosForGroup:iosDevCourseGroupID
            forAlbumID:self.albumID
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
                     
                     
//                     [self.collectionView reloadData];
                 }
                 
                 self.loadingData = NO;
                 
                 
             }
             onFailure:^(NSError *error, NSInteger statusCode) {
                 NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
             }];
    
}



- (void) refreshPhotos {
    
    if (self.loadingData == NO) {
        self.loadingData = YES;
        
        
        [[ANServerManager sharedManager] getPhotosForGroup:iosDevCourseGroupID
                forAlbumID:self.albumID
                withOffset:0
                     count:MAX(requestCount, [self.photosArray count])
                 onSuccess:^(NSArray *photos) {
                     
                     if ([photos count] > 0) {
                         [self.photosArray removeAllObjects];
                         [self.photosArray addObjectsFromArray:photos];
                         
                         [self.collectionView reloadData];
                     }
                     
                     self.loadingData = NO;
                     [self.refreshControl endRefreshing];
                     
                     
                 }
                 onFailure:^(NSError *error, NSInteger statusCode) {
                     NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
                     [self.refreshControl endRefreshing];

                 }];
        
    }
    
    
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
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
        NSLog(@"scrollViewDidScroll");
        if (!self.loadingData)
        {
            self.loadingData = YES;
            [self getPhotosFromServer];
        }
    }
}


#pragma mark - Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addNewPhoto"]) {
        
        ANPhotoAddingViewController* vc = segue.destinationViewController;
        
        vc.albumID = self.albumID;
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
    
    NSInteger currentViewingPhotoIndex = [self.photosArray indexOfObject:self.currentViewingPhoto];
    NSInteger iteratedPhotoIndex;
    
    if (iterationDirection == ANPhotoIterationDirectionNext) {
        
        NSLog(@"iteratePhoto Next");
        
        if ([self.currentViewingPhoto isEqual:[self.photosArray lastObject]]) {
            iteratedPhoto = [self.photosArray firstObject];
            
        } else {
            
            iteratedPhotoIndex = currentViewingPhotoIndex + 1;
            
            iteratedPhoto = [self.photosArray objectAtIndex:iteratedPhotoIndex];
        }
        
    } else {
        
        NSLog(@"iteratePhoto Previous");

        if ([self.currentViewingPhoto isEqual:[self.photosArray firstObject]]) {
            iteratedPhoto = [self.photosArray lastObject];
            
        } else {
            
            iteratedPhotoIndex = currentViewingPhotoIndex - 1;
            
            iteratedPhoto = [self.photosArray objectAtIndex:iteratedPhotoIndex];

        }
        
    }
    
    self.currentViewingPhoto = iteratedPhoto;
    
    return iteratedPhoto;
    
}




@end