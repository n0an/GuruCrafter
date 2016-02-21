//
//  ANPhotoDetailsViewController.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 21/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANPhotoDetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "ANPhoto.h"

@interface ANPhotoDetailsViewController ()

@end

@implementation ANPhotoDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    CGFloat withPhoto = (CGFloat)self.photo.width;
    CGFloat heightPhoto = (CGFloat)self.photo.height;

    CGFloat ratio = withPhoto / heightPhoto;
    
    CGFloat newWith, newHeight;
    CGRect rectForPhoto;
    
    if (ratio >= 1) {
        newWith = CGRectGetWidth(self.view.frame);
        newHeight = newWith / ratio;
        
        CGFloat verticalCenter = CGRectGetMidY(self.view.frame);
        
        rectForPhoto = CGRectMake(0, verticalCenter -newHeight/2, newWith, newHeight);
        
    } else {
        newHeight = CGRectGetHeight(self.view.frame) - 100;
        newWith = newHeight * ratio;
        
        CGFloat horizontalCenter = CGRectGetMidX(self.view.frame);
        
        rectForPhoto = CGRectMake(horizontalCenter - newWith/2, 0, newWith, newHeight);
    }
    
//    self.photoImageView.frame = rectForPhoto;
//    
//    [self.view layoutSubviews];
    
    
    NSURL* photoURL = [NSURL URLWithString:self.photo.maxRes];
    
//    [self.photoImageView setImageWithURL:photoURL];
    
    

    UIImageView* photoImage = [[UIImageView alloc] initWithFrame:rectForPhoto];

    [photoImage setImageWithURL:photoURL];
    
    [self.view addSubview:photoImage];
    
    
    self.photoDescriptionLabel.text = self.photo.text;
    self.likeButton.titleLabel.text = self.photo.likesCount;
    
    UIBarButtonItem* cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancel:)];
    
    self.navigationItem.leftBarButtonItem = cancel;
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];

    
//    [self.navigationController.navigationBar setBackgroundColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];

}



#pragma mark - Actions

- (void) actionCancel:(UIBarButtonItem*) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
