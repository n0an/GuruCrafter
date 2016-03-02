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
    
    
    self.photoImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer* tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionOnTapImage:)];
    
    UISwipeGestureRecognizer* rightSwipeGesture =
    [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipe:)];
    rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer* leftSwipeGesture =
    [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwipe:)];
    leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer* upDownGesture =
    [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleUpDownSwipe:)];
    upDownGesture.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
    
    
    [self.photoImageView addGestureRecognizer:rightSwipeGesture];
    [self.photoImageView addGestureRecognizer:leftSwipeGesture];
    [self.photoImageView addGestureRecognizer:upDownGesture];


    [self.photoImageView addGestureRecognizer:tapGesture];
    

    self.isLabelsVisible = YES;
    
    self.photoDescriptionLabel.hidden = NO;
    self.likeButton.hidden = NO;
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
    
    self.photoDescriptionLabel.text = self.photo.text;
    self.likeButton.titleLabel.text = self.photo.likesCount;
    
    self.photoImageView.image = nil;
    
    
    NSString* linkToNeededRes;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        linkToNeededRes = self.photo.maxRes;
        
    } else {
        
        if (self.photo.photo_1280) {
            linkToNeededRes = self.photo.photo_1280;
        } else {
            linkToNeededRes = self.photo.maxRes;
        }
        
    }
    
 
    
    NSURL* photoURL = [NSURL URLWithString:linkToNeededRes];
    

    // Animated setting photo in UIImageView
    
    NSURLRequest* photuURLRequest = [NSURLRequest requestWithURL:photoURL];
    
    __block UIImageView* weakPhotoImageView = self.photoImageView;
    
    [self.photoImageView
     setImageWithURLRequest:photuURLRequest
     placeholderImage:nil
     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
         
         [UIView transitionWithView:weakPhotoImageView
                           duration:0.4f
                            options:UIViewAnimationOptionTransitionCrossDissolve
                         animations:^{
                             weakPhotoImageView.image = image;
                         }
                         completion:nil];
         
         
     }
     failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
         
     }];


}




- (void) iterateAndSetPhotoUsingDirection:(ANPhotoIterationDirection) iterationDirection {
    
    self.photo = [self.delegate iteratePhoto:iterationDirection];
    
    [self settingImage];
    
}


#pragma mark - Actions

- (void) actionCancel:(UIBarButtonItem*) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void) actionNextPressed:(UIBarButtonItem*) sender {
    NSLog(@"actionNextPressed");
    
    // Send message to delegate, to get Next photo from album
    
    [self iterateAndSetPhotoUsingDirection:ANPhotoIterationDirectionNext];
    
}

- (void) actionPreviousPressed:(UIBarButtonItem*) sender {
    NSLog(@"actionPreviousPressed");
    
    // Send message to delegate, to get Previous photo from album
    
    [self iterateAndSetPhotoUsingDirection:ANPhotoIterationDirectionPrevious];

}



- (void) actionOnTapImage: (UITapGestureRecognizer*) recognizer {
    
    if (self.isLabelsVisible == YES) {
        
        self.isLabelsVisible = NO;
        
        self.navigationController.navigationBar.hidden = YES;
        self.photoDescriptionLabel.hidden = YES;
        self.likeButton.hidden = YES;
        
    } else {
        
        self.isLabelsVisible = YES;
        
        self.navigationController.navigationBar.hidden = NO;
        self.photoDescriptionLabel.hidden = NO;
        self.likeButton.hidden = NO;
    }
    
}


- (void) handleRightSwipe: (UITapGestureRecognizer*) recognizer {
    
    [self iterateAndSetPhotoUsingDirection:ANPhotoIterationDirectionPrevious];

}

- (void) handleLeftSwipe: (UITapGestureRecognizer*) recognizer {
    
    [self iterateAndSetPhotoUsingDirection:ANPhotoIterationDirectionNext];

}

- (void) handleUpDownSwipe: (UITapGestureRecognizer*) recognizer {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}


@end






