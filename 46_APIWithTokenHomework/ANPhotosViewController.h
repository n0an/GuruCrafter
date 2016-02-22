//
//  ANPhotosViewController.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 21/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ANPhotosViewController : UIViewController

@property (strong, nonatomic) NSString* albumID;

@property (weak, nonatomic) IBOutlet UICollectionView* collectionView;


- (IBAction)actionAddButtonPressed:(UIBarButtonItem*)sender;

@end
