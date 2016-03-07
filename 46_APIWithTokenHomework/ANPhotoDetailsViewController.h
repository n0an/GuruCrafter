//
//  ANPhotoDetailsViewController.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 21/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ANPhotoIterationDirectionNext,
    ANPhotoIterationDirectionPrevious

} ANPhotoIterationDirection;

@protocol ANPhotoViewerDelegate;

@class ANPhoto;



@interface ANPhotoDetailsViewController : UIViewController

@property (strong, nonatomic) ANPhoto* photo;


@property (weak, nonatomic) IBOutlet UIImageView* photoImageView;

@property (weak, nonatomic) IBOutlet UILabel* photoDescriptionLabel;

@property (weak, nonatomic) IBOutlet UIButton* likeButton;

@property (weak, nonatomic) id <ANPhotoViewerDelegate> delegate;


@end


@protocol ANPhotoViewerDelegate <NSObject>

@required

- (ANPhoto*) iteratePhoto:(ANPhotoIterationDirection) iterationDirection;

@end