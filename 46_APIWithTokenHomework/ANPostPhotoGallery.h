//
//  ANPostPhotoGallery.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 02/03/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ANPost;
@class ANPostCell;

@interface ANPostPhotoGallery : NSObject



@property (assign, nonatomic) CGFloat maxAvailableSpaceToOperate;

@property (assign, nonatomic) CGFloat tableViewWidth;



- (instancetype)initWithTableViewWidth:(CGFloat) tableViewWidth;

- (void) insertGalleryOfPost:(ANPost*)post toCell:(ANPostCell*) postCell;



@end
