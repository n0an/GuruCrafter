//
//  ANPostCell.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 07/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ANPostCellDelegate;

@interface ANPostCell : UITableViewCell

@property (strong, nonatomic) NSString* postID;

@property (weak, nonatomic) IBOutlet UILabel* postTextLabel;
@property (weak, nonatomic) IBOutlet UILabel* dateLabel;

@property (weak, nonatomic) IBOutlet UILabel* fullNameLabel;


@property (weak, nonatomic) IBOutlet UILabel* commentsCountLabel;

@property (weak, nonatomic) IBOutlet UIImageView* postAuthorImageView;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *glryImageViews;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *photoWidths;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *photoHeights;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint* galleryFirstRowLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* gallerySecondRowLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* gallerySecondRowTopConstraint;



@property (weak, nonatomic) IBOutlet UIButton* likeButton;
@property (weak, nonatomic) IBOutlet UIButton* commentButton;

//+ (CGFloat) heightForText:(NSString*) text;

- (IBAction)actionLikePressed:(UIButton*)sender;


@property (strong, nonatomic) id <ANPostCellDelegate> delegate;



@end


@protocol ANPostCellDelegate <NSObject>

@required

- (void) likeButtonPressedForPostID:(NSString*) postID;

@end
