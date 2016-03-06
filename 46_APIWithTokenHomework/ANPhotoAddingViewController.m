//
//  ANPhotoAddingViewController.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 25/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANPhotoAddingViewController.h"
#import "ANServerManager.h"
#import "ANUploadServer.h"

@interface ANPhotoAddingViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (strong, nonatomic) UIImage* selectedImage;

@end

static NSString* iosDevCourseGroupID = @"58860049";
static NSString* myVKAccountID = @"21743772";

@implementation ANPhotoAddingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"ANPhotoAddingViewController self.albumID = %@", self.albumID);
    
    self.waitView.hidden = YES;
    
    self.uploadBarButton.enabled = NO;
    self.hintLabel.hidden = NO;
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.cameraButton.enabled = NO;
        [self showAlertNoCameraDeviceFound];
    }
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Helper Methods

- (void) showAlertNoCameraDeviceFound {
    
    UIAlertController* alertNoCamera =
    [UIAlertController alertControllerWithTitle:@"Error"
                                        message:@"Device has no camera"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesAction =
    [UIAlertAction actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * _Nonnull action) {
                               [alertNoCamera dismissViewControllerAnimated:YES completion:nil];
                           }];
    
    [alertNoCamera addAction:yesAction];
    
    [self presentViewController:alertNoCamera animated:YES completion:nil];
    
    
}


#pragma mark - Actions

- (IBAction)actionCameraButtonPressed:(UIBarButtonItem*)sender {
    NSLog(@"actionCameraButtonPressed");
    
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    
    imagePicker.allowsEditing = YES;
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
    
    
}

- (IBAction)actionFolderButtonPressed:(UIBarButtonItem*)sender {
    NSLog(@"actionFolderButtonPressed");
    
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    
    imagePicker.allowsEditing = YES;
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:imagePicker animated:YES completion:nil];

}

- (IBAction)actionUploadButtonPressed:(UIBarButtonItem*)sender {
    NSLog(@"actionUploadButtonPressed");
    
    [self uploadSelectedImageToServer];

    self.photoPreviewImageView.image = nil;
    self.waitView.hidden = NO;
    
    
}




#pragma mark - API methods for uploading photos to group album
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
                 
                 self.waitView.hidden = YES;

                 self.hintLabel.hidden = NO;
                 self.hintLabel.text = @"Photo uploaded successfully!\n You can upload more photos now.";
                 self.uploadBarButton.enabled = NO;
                 
                 [self.delegate photoDidFinishUploading];
                 
             }
             onFailure:^(NSError *error, NSInteger statusCode) {
                 
                 NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
             }];
    }





#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    NSLog(@"didFinishPickingMediaWithInfo = %@", info);
    
    self.selectedImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    if (self.selectedImage) {
        self.photoPreviewImageView.image = self.selectedImage;
        self.hintLabel.hidden = YES;
        self.uploadBarButton.enabled = YES;
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"imagePickerControllerDidCancel");
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}



@end
