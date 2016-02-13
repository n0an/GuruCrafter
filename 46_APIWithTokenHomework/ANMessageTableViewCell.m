//
//  ANMessageTableViewCell.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 13/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANMessageTableViewCell.h"

@implementation ANMessageTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.messageAuthorImageView.layer.cornerRadius = self.messageAuthorImageView.frame.size.height/2;
    self.messageAuthorImageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
