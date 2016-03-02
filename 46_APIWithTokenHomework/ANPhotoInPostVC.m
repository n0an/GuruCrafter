//
//  ANPhotoInPostVC.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 02/03/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANPhotoInPostVC.h"
#import "ANPhoto.h"
#import "UIImageView+AFNetworking.h"

typedef enum {
    ANPhotoIterationDirectionNext,
    ANPhotoIterationDirectionPrevious
    
} ANPhotoIterationDirection;


@interface ANPhotoInPostVC ()

@property (assign, nonatomic) NSInteger currentIndex;

@end

@implementation ANPhotoInPostVC



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self settingImage];
    
    self.currentIndex = [self.photosArray indexOfObject:self.currentPhoto];
    
    self.navigationController.hidesBarsOnTap = YES;
    
    [self.navigationController barHideOnTapGestureRecognizer];
    
    
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

    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Helper Methods

- (void) settingImage {

    self.photoImageView.userInteractionEnabled = YES;
    
    self.photoImageView.image = nil;
    
    NSString* linkToNeededRes;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        linkToNeededRes = self.currentPhoto.maxRes;
        
    } else {
        
        if (self.currentPhoto.photo_1280) {
            linkToNeededRes = self.currentPhoto.photo_1280;
        } else {
            linkToNeededRes = self.currentPhoto.maxRes;
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


- (ANPhoto*) iteratePhoto:(ANPhotoIterationDirection) iterationDirection {
    
    ANPhoto* iteratedPhoto;
    
    NSInteger currentViewingPhotoIndex = [self.photosArray indexOfObject:self.currentPhoto];
    NSInteger iteratedPhotoIndex;
    
    if (iterationDirection == ANPhotoIterationDirectionNext) {
        
        NSLog(@"iteratePhoto Next");
        
        if ([self.currentPhoto isEqual:[self.photosArray lastObject]]) {
            iteratedPhoto = [self.photosArray firstObject];
            
        } else {
            
            iteratedPhotoIndex = currentViewingPhotoIndex + 1;
            
            iteratedPhoto = [self.photosArray objectAtIndex:iteratedPhotoIndex];
        }
        
    } else {
        
        NSLog(@"iteratePhoto Previous");
        
        if ([self.currentPhoto isEqual:[self.photosArray firstObject]]) {
            iteratedPhoto = [self.photosArray lastObject];
            
        } else {
            
            iteratedPhotoIndex = currentViewingPhotoIndex - 1;
            
            iteratedPhoto = [self.photosArray objectAtIndex:iteratedPhotoIndex];
            
        }
        
    }
    
    self.currentPhoto = iteratedPhoto;
    
    return iteratedPhoto;
    
}

- (void) iterateAndSetPhotoUsingDirection:(ANPhotoIterationDirection) iterationDirection {
    
    self.currentPhoto = [self iteratePhoto:iterationDirection];
    
    [self settingImage];
    
}

#pragma mark - Actions

- (IBAction)actionPreviousPhotoButtonPressed:(UIBarButtonItem*)sender {
    
    NSLog(@"actionPreviousPhotoButtonPressed");
    
    self.currentPhoto = [self iteratePhoto:ANPhotoIterationDirectionPrevious];
    
    [self settingImage];
    
}


- (IBAction)actionNextPhotoButtonPressed:(UIBarButtonItem*)sender {
    
    NSLog(@"actionNextPhotoButtonPressed");

    self.currentPhoto = [self iteratePhoto:ANPhotoIterationDirectionNext];
    
    [self settingImage];
}




#pragma mark - Gestures

- (void) handleRightSwipe: (UITapGestureRecognizer*) recognizer {
    
    [self iterateAndSetPhotoUsingDirection:ANPhotoIterationDirectionPrevious];
    
    
}

- (void) handleLeftSwipe: (UITapGestureRecognizer*) recognizer {
    
    [self iterateAndSetPhotoUsingDirection:ANPhotoIterationDirectionNext];
    
    
}


- (void) handleUpDownSwipe: (UITapGestureRecognizer*) recognizer {
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
}














@end
