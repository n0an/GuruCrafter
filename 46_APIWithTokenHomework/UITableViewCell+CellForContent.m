//
//  UITableViewCell+CellForContent.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 04/03/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "UITableViewCell+CellForContent.h"

@implementation UITableViewCell (CellForContent)



+ (UITableViewCell*) getParentCellFor:(UIView*) view {
    
    UIView* superView = [view superview];
    
    if (!superView) {
        return nil;
    } else if (![superView isKindOfClass:[UITableViewCell class]]) {
        return [self getParentCellFor:superView];
    } else {
        return (UITableViewCell*)superView;
    }
    return nil;
}


@end
