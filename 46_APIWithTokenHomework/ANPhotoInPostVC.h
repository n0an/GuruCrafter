//
//  ANPhotoInPostVC.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 02/03/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ANPhoto;

@interface ANPhotoInPostVC : UIViewController

@property (strong, nonatomic) ANPhoto* currentPhoto;

@property (strong, nonatomic) NSArray* photosArray;


@property (weak, nonatomic) IBOutlet UIImageView* photoImageView;


- (IBAction)actionPreviousPhotoButtonPressed:(UIBarButtonItem*)sender;
- (IBAction)actionNextPhotoButtonPressed:(UIBarButtonItem*)sender;


@end
