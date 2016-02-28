//
//  ANPhotoAlbumsViewController.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 20/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANPhotoAlbumsViewController.h"
#import "ANServerManager.h"
#import "ANPhotoAlbum.h"
#import "ANPhotoAlbumCellCollectionViewCell.h"

#import "UIImageView+AFNetworking.h"

#import "ANPhotosViewController.h"


@interface ANPhotoAlbumsViewController ()

@property (strong, nonatomic) NSMutableArray* albumsArray;
@property (assign, nonatomic) BOOL loadingData;

@end


static NSInteger requestCount = 20;
static NSString* iosDevCourseGroupID = @"58860049";
static NSString* myVKAccountID = @"21743772";


@implementation ANPhotoAlbumsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.albumsArray = [NSMutableArray array];
    
    self.loadingData = YES;
    
    
    [self getAlbumsFromServer];
    
}



#pragma mark - API

- (void) getAlbumsFromServer {
    
    [[ANServerManager sharedManager] getGroupAlbums:iosDevCourseGroupID
             withOffset:0
                  count:0
              onSuccess:^(NSArray *photoAlbums) {
                  
                  if ([photoAlbums count] > 0) {
                      [self.albumsArray addObjectsFromArray:photoAlbums];
                      
                      [self.collectionView reloadData];
                  }
                  
                  self.loadingData = NO;
                  
 
              }
              onFailure:^(NSError *error, NSInteger statusCode) {
                  NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
              }];

}


#pragma mark - UICollectionViewDataSource


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.albumsArray count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* albumIdentifier = @"albumCVCell";
    
    ANPhotoAlbumCellCollectionViewCell* albumCVCell = (ANPhotoAlbumCellCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:albumIdentifier forIndexPath:indexPath];
    
    ANPhotoAlbum* photoAlbum = [self.albumsArray objectAtIndex:indexPath.row];
    
    albumCVCell.albumTitleLabel.text = photoAlbum.albumTitle;
    albumCVCell.albumSizeLabel.text = [NSString stringWithFormat:@"%@ photos", photoAlbum.albumSize];
    

    
    NSURLRequest* albumThumbRequest = [NSURLRequest requestWithURL:photoAlbum.albumThumbImageURL];
    
    __block UIImageView* weakAlbumThumbImageView = albumCVCell.albumThumbImageView;
    
    [albumCVCell.albumThumbImageView
     setImageWithURLRequest:albumThumbRequest
     placeholderImage:nil
     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
         
         
         [UIView transitionWithView:weakAlbumThumbImageView
                           duration:0.3f
                            options:UIViewAnimationOptionTransitionCrossDissolve
                         animations:^{
                             weakAlbumThumbImageView.image = image;
                         }
                         completion:nil];
         
         
     }
     failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
         
     }];


    
    return albumCVCell;
}



- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showPhotosInAlbum"]) {
        ANPhotoAlbumCellCollectionViewCell* cell = (ANPhotoAlbumCellCollectionViewCell*) sender;
        
        NSIndexPath* path = [self.collectionView indexPathForCell:cell];
        
        ANPhotoAlbum* album = [self.albumsArray objectAtIndex:path.row];
        
        
        ANPhotosViewController* vc = segue.destinationViewController;
        
        vc.albumID = album.albumID;
        
        NSLog(@"vc.allbumID = %@", vc.albumID);
        
    }
}





@end
