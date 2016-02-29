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

@property (assign, nonatomic) BOOL isLabelsVisible;

@end

@implementation ANPhotoDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self settingImage];
    
    self.isLabelsVisible = NO;
    
    self.photoImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionOnTapImage:)];
    [self.photoImageView addGestureRecognizer:tapGesture];
    

    self.photoDescriptionLabel.hidden = YES;
    self.likeButton.hidden = YES;
    self.likeButton.userInteractionEnabled = NO;
    
    
    
    
    UIBarButtonItem* cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancel:)];
    
    self.navigationItem.leftBarButtonItem = cancel;
    
    
    UIBarButtonItem* nextButton = [[UIBarButtonItem alloc] initWithTitle:@">" style:UIBarButtonItemStylePlain target:self action:@selector(actionNextPressed:)];
    
    UIBarButtonItem* previousButton = [[UIBarButtonItem alloc] initWithTitle:@"<" style:UIBarButtonItemStylePlain target:self action:@selector(actionPreviousPressed:)];
    
    UIBarButtonItem* fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    fixedSpace.width = 50;
    

    self.navigationItem.rightBarButtonItems = @[nextButton, fixedSpace, previousButton];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];

    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];

}

#pragma mark - Helper methods

- (void) settingImage {
    
    NSURL* photoURL = [NSURL URLWithString:self.photo.photo_604];
    
    [self.photoImageView setImageWithURL:photoURL];
    
    self.photoDescriptionLabel.text = self.photo.text;
    self.likeButton.titleLabel.text = self.photo.likesCount;

}


#pragma mark - Actions

- (void) actionCancel:(UIBarButtonItem*) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void) actionNextPressed:(UIBarButtonItem*) sender {
    NSLog(@"actionNextPressed");
    
    // Send message to delegate, to get Next photo from album
    
    self.photo = [self.delegate iteratePhoto:ANPhotoIterationDirectionNext];
    
    [self settingImage];
    
}

- (void) actionPreviousPressed:(UIBarButtonItem*) sender {
    NSLog(@"actionPreviousPressed");
    
    // Send message to delegate, to get Previous photo from album
    
    self.photo = [self.delegate iteratePhoto:ANPhotoIterationDirectionPrevious];
    
    [self settingImage];
    
}



- (void) actionOnTapImage: (UITapGestureRecognizer*) recognizer {
    
    if (self.isLabelsVisible == YES) {
        self.isLabelsVisible = NO;
        self.photoDescriptionLabel.hidden = YES;
        self.likeButton.hidden = YES;
    } else {
        self.isLabelsVisible = YES;
        self.photoDescriptionLabel.hidden = NO;
        self.likeButton.hidden = NO;
    }
    

}







@end






