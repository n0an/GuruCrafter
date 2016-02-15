//
//  ANNewPostCell.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 15/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANNewPostCell.h"

@implementation ANNewPostCell

- (void)awakeFromNib {
    // Initialization code
    
    self.addPostButton.layer.cornerRadius = 10;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
