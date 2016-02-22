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


@interface ANPhotosViewController () <UIScrollViewDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (strong, nonatomic) NSMutableArray* photosArray;
@property (assign, nonatomic) BOOL loadingData;

@property (strong, nonatomic) UIImage* selectedImage;

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


#pragma mark - Actions

- (IBAction)actionAddButtonPressed:(UIBarButtonItem*)sender {
    
    NSLog(@"actionAddButtonPressed");
    
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    
    imagePicker.allowsEditing = YES;
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:imagePicker animated:YES completion:nil];

    
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
                 NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
             }];
    
}

#pragma mark -- API methods for uploading photos to group album
/**
 1. Getting Upload Server - getting URL of server
 2. Getting ParsedServer parameters using URL - getting Server ID, Hash, Photos_list string, Album ID and Group ID
 3. Trigger Upload using ParsedServer
 */

- (void) uploadSelectedImageToServer {
    
    NSData* selectedImageData = UIImageJPEGRepresentation(self.selectedImage, 1.0f);
    
    [[ANServerManager sharedManager] getUploadServerForGroupID:iosDevCourseGroupID
       forPhotoAlbumID:self.albumID
             onSuccess:^(ANUploadServer *uploadServer) {
                 
                 [self getParsedUploadServerForUploadServer:uploadServer andImageData:selectedImageData];
                 
             }
             onFailure:^(NSError *error, NSInteger statusCode) {
                 NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
             }];
    
}

- (void) getParsedUploadServerForUploadServer:(ANUploadServer*) uploadServer andImageData:(NSData*)imageData {
    
    [[ANServerManager sharedManager] getUploadJSONStringForServerURL:uploadServer.uploadURL
        fileToUpload:imageData
           onSuccess:^(ANParsedUploadServer *parsedUploadServer) {
               
               NSLog(@"parsedUploadServer = %@", parsedUploadServer);
               
               [self uploadPhotosToServer:parsedUploadServer];
               
           } onFailure:^(NSError *error, NSInteger statusCode) {
               NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
           }];

}


- (void) uploadPhotosToServer:(ANParsedUploadServer*) parsedUploadServer {
    [[ANServerManager sharedManager] uploadPhotosToGroupWithServer:parsedUploadServer
         onSuccess:^(id result) {
             
             NSLog(@"result = %@", result);

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
    
    NSURL* photoURL = [NSURL URLWithString:photo.photo_604];
    
    [photoCVCell.photoImageView setImageWithURL:photoURL];
    
    return photoCVCell;
}



#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
 
    ANPhoto* selectedPhoto = [self.photosArray objectAtIndex:indexPath.row];
    
    ANPhotoDetailsViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ANPhotoDetailsViewController"];
    vc.photo = selectedPhoto;
    
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nav animated:YES completion:nil];
    
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    NSLog(@"didFinishPickingMediaWithInfo = %@", info);
    
    self.selectedImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self uploadSelectedImageToServer];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"imagePickerControllerDidCancel");
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}



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


@end
