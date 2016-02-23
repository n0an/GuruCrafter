//
//  ANVideoCell.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 23/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ANVideoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView* videoThumbImageVIew;
@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UILabel* dateLabel;
@property (weak, nonatomic) IBOutlet UILabel* durationLabel;
@property (weak, nonatomic) IBOutlet UILabel* viewsCountLabel;



@end
