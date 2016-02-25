//
//  ANPhotoAddingViewController.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 25/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ANPhotoAddingViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem* uploadBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem* cameraButton;
@property (weak, nonatomic) IBOutlet UIImageView* photoPreviewImageView;
@property (weak, nonatomic) IBOutlet UILabel* hintLabel;

@property (weak, nonatomic) IBOutlet UIStackView* waitView;

@property (strong, nonatomic) NSString* albumID;


- (IBAction)actionCameraButtonPressed:(UIBarButtonItem*)sender;
- (IBAction)actionFolderButtonPressed:(UIBarButtonItem*)sender;
- (IBAction)actionUploadButtonPressed:(UIBarButtonItem*)sender;



@end
