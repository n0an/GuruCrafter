//
//  ANPostCell.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 07/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANPostCell.h"

@implementation ANPostCell

- (void)awakeFromNib {
    // Initialization code
    
    self.postAuthorImageView.layer.cornerRadius = self.postAuthorImageView.frame.size.height/2;
    self.postAuthorImageView.clipsToBounds = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



- (IBAction)actionLikePressed:(UIButton*)sender {
    
    NSLog(@"actionLikePressed, postID = %@", self.postID);
    
    [self.delegate likeButtonPressedForPostID:self.postID];
}






@end
