//
//  ANMessageTableViewCell.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 13/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ANMessageTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel* messageTextLabel;
@property (weak, nonatomic) IBOutlet UILabel* messageDateLabel;

@property (weak, nonatomic) IBOutlet UILabel* messageAuthorFullNameLabel;

@property (weak, nonatomic) IBOutlet UIImageView* messageAuthorImageView;

@end
