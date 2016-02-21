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


@interface ANPhotosViewController ()
@property (strong, nonatomic) NSMutableArray* photosArray;
@property (assign, nonatomic) BOOL loadingData;
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
                     
                     [self.collectionView reloadData];
                 }
                 
                 self.loadingData = NO;
                 
                 
             }
             onFailure:^(NSError *error, NSInteger statusCode) {
                 
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
    
    NSURL* photoURL = [NSURL URLWithString:photo.photo_604];
    
    [photoCVCell.photoImageView setImageWithURL:photoURL];
    
    
    
    
    return photoCVCell;
}



@end
