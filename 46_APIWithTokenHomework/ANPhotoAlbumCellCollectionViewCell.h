//
//  ANPhotoAlbumCellCollectionViewCell.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 20/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ANPhotoAlbumCellCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView* albumThumbImageView;
@property (weak, nonatomic) IBOutlet UILabel* albumTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel* albumSizeLabel;


@end
