//
//  ANPostCell.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 07/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ANPostCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* postTextLabel;
@property (weak, nonatomic) IBOutlet UILabel* dateLabel;

@property (weak, nonatomic) IBOutlet UILabel* fullNameLabel;


@property (weak, nonatomic) IBOutlet UILabel* commentsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel* likesCountLabel;

@property (weak, nonatomic) IBOutlet UIImageView* postAuthorImageView;
@property (weak, nonatomic) IBOutlet UIImageView* postImageView;




+ (CGFloat) heightForText:(NSString*) text;



@end