//
//  ANPostPhotoGallery.m
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 02/03/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANPostPhotoGallery.h"
#import "ANPhoto.h"
#import "ANPostCell.h"
#import "ANPost.h"

#import "UIImageView+AFNetworking.h"



NSInteger firstRowCount = 3;

@implementation ANPostPhotoGallery



- (instancetype)initWithTableViewWidth:(CGFloat) tableViewWidth
{
    self = [super init];
    if (self) {
        
        self.tableViewWidth = tableViewWidth;
        
        
    }
    return self;
}




- (void) insertGalleryOfPost:(ANPost*)post toCell:(ANPostCell*) postCell {
    
    
    /**********************
     * SHOW IMAGES IN POST
     **********************
     */
    
    
    /*-- PART 1. CHECKINGS --
     */
    //  If post contains no photos - set all ImageViews height to 0 (collapsing all Gallery ImageViews), and return cell immediately
    if ([post.attachmentsArray count] == 0) {
        postCell.gallerySecondRowTopConstraint.constant = 0;
        
        for (NSLayoutConstraint* heightOfImageView in postCell.photoHeights) {
            heightOfImageView.constant = 0;
        }
        
        return;
    }
    
    
    //  Check of attachments array before start main loop. If occasionally, there's photo with width or height equals to 0 - remove this photo from attachments array
    for (int i = 0; i < [post.attachmentsArray count]; ) {
        ANPhoto* photo = [post.attachmentsArray objectAtIndex:i];
        if (photo.width == 0 || photo.height == 0){
            NSMutableArray* tmpArray = [NSMutableArray arrayWithArray:post.attachmentsArray];
            [tmpArray removeObject:photo];
            post.attachmentsArray = tmpArray;
            continue;
        }
        i++;
    }
    
    
    
    /*-- PART 2. CALCULATIONS OF MAXIMUM SIZES FOR SQUARE GALLERY IMAGEVIEWS --
     */
    
    //  Calculation of Gallery ImageViews Maximum Sizes (depending on count of photos)
    
    CGFloat maxRequiredSizeOfImageInFirstRow = 0;
    CGFloat maxRequiredSizeOfImageInSecondRow = 0;
    
    
    CGFloat maxAvailableSpaceToOperate = MIN(self.tableViewWidth, 1300);

    
    if ([post.attachmentsArray count] <= firstRowCount) { // If we have 3 or less photos - use only ONE row of Gallery
        
        maxRequiredSizeOfImageInFirstRow = (maxAvailableSpaceToOperate - 16 - 4 * ([post.attachmentsArray count] - 1))/ [post.attachmentsArray count];
        
        maxRequiredSizeOfImageInFirstRow = MIN(maxRequiredSizeOfImageInFirstRow, 800); // Limit to 800
        
    } else { //** If we have more than 3 photos - use TWO rows of Gallery
        
        
        maxRequiredSizeOfImageInFirstRow = (maxAvailableSpaceToOperate - 16 - 4 * (firstRowCount - 1)) / 3;
        
        maxRequiredSizeOfImageInSecondRow =
        (self.maxAvailableSpaceToOperate - 16 - 4 * ([post.attachmentsArray count] - firstRowCount - 1)) / ([post.attachmentsArray count] - firstRowCount);
        
        maxRequiredSizeOfImageInSecondRow = MIN(maxRequiredSizeOfImageInSecondRow, 800); // Limit to 800
        
        
    }
    
    
    
    
    /*-- PART 3. LOOP THROUGH PHOTOS IN ATTACHMENTS ARRAY AND HANDLE EACH PHOTO --
     */
    
    UIImage* placeHolderImage = [[UIImage alloc] init];
    
    CGFloat maxHeigthFirstRow = 0;
    CGFloat fullWidthFirstRow = 0;
    CGFloat fullWidthSecondRow = 0;
    
    // *********^^^^^^^ MAIN LOOP FOR STARTS HERE ^^^^^^^****************
    for (int i = 0; i < ([post.attachmentsArray count]) && (i < firstRowCount * 2); i++) {
        
        ANPhoto* photo = [post.attachmentsArray objectAtIndex:i];
        
        // * 1. Calculating width and height of current photo, according to calculated maxSize of square ImageView. If there's portrait photo - currentHeight = maxSize, if album oriented - currentWidth = maxSize
        
        CGFloat ratio = (CGFloat)photo.width / photo.height;
        
        CGFloat heightOfCurrentPhoto;
        CGFloat widthOfCurrentPhoto;
        
        if (ratio < 1) { // ** Portrait oriented photo
            
            if (i < firstRowCount) { // *** First Row of Gallery
                
                heightOfCurrentPhoto = maxRequiredSizeOfImageInFirstRow;
                
                widthOfCurrentPhoto = heightOfCurrentPhoto * ratio;
                fullWidthFirstRow += widthOfCurrentPhoto;
                
            } else { // *** Second Row of Gallery
                
                heightOfCurrentPhoto = maxRequiredSizeOfImageInSecondRow;
                
                widthOfCurrentPhoto = heightOfCurrentPhoto * ratio;
                fullWidthSecondRow += widthOfCurrentPhoto;
            }
            
            
        } else { // ** Landscape oriented photo
            
            if (i < firstRowCount) { // *** First Row of Gallery
                
                widthOfCurrentPhoto = maxRequiredSizeOfImageInFirstRow;
                fullWidthFirstRow += widthOfCurrentPhoto;
                
            } else { // *** Second Row of Gallery
                
                widthOfCurrentPhoto = maxRequiredSizeOfImageInSecondRow;
                fullWidthSecondRow += widthOfCurrentPhoto;
                
            }
            
            heightOfCurrentPhoto = widthOfCurrentPhoto / ratio;
        }
        
        
        // * 2. Calculating height of FirstRow to get know value for gallerySecondRowTopConstraint
        if (heightOfCurrentPhoto > maxHeigthFirstRow && i < firstRowCount) {
            maxHeigthFirstRow = heightOfCurrentPhoto;
        }
        
        // * 3. Setting width and height constraints for current photo and setting frame
        NSLayoutConstraint* photoHightConstraint = [postCell.photoHeights objectAtIndex:i];
        photoHightConstraint.constant = heightOfCurrentPhoto;
        
        NSLayoutConstraint* photoWidthConstraint = [postCell.photoWidths objectAtIndex:i];
        photoWidthConstraint.constant = widthOfCurrentPhoto;
        
        
        UIImageView* currentImageView = [postCell.glryImageViews objectAtIndex:i];
        
        CGPoint currentImageViewOrigin = currentImageView.frame.origin;
        
        currentImageView.frame = CGRectMake(currentImageViewOrigin.x,
                                            currentImageViewOrigin.y,
                                            widthOfCurrentPhoto, heightOfCurrentPhoto);
        
        // * 4. Loading and setting image
        
        
        NSString* linkToNeededRes;
        ANPhotoResolution neededRes;
        
        if (i < firstRowCount) {
            
            if (maxRequiredSizeOfImageInFirstRow > 600) {
                linkToNeededRes = photo.photo_807;
                neededRes = ANPhotoResolution807;
            } else {
                linkToNeededRes = photo.photo_604;
                neededRes = ANPhotoResolution604;
                
            }
            
            
        } else {
            
            if (maxRequiredSizeOfImageInSecondRow > 600) {
                linkToNeededRes = photo.photo_807;
                neededRes = ANPhotoResolution807;
                
            } else {
                linkToNeededRes = photo.photo_604;
                neededRes = ANPhotoResolution604;
                
            }
            
        }
        
        if (!linkToNeededRes) {
            
            for (ANPhotoResolution i = neededRes - 1; i >= ANPhotoResolution_First; i--) {
                
                NSString* lessResolutionKey = [photo.keysResArray objectAtIndex:i];
                
                NSString* lessResolution = [photo.resolutionsDictionary objectForKey:lessResolutionKey];
                
                if (lessResolution) {
                    linkToNeededRes = lessResolution;
                    break;
                }
                
                
            }
            
        }
        
        
        
        NSURL* urlPhoto = [NSURL URLWithString:linkToNeededRes];
        
        NSURLRequest* photoRequest = [NSURLRequest requestWithURL:urlPhoto];
        
        __block UIImageView* weakCurrentImageView = currentImageView;
        
        [currentImageView setImageWithURLRequest:photoRequest
                                placeholderImage:placeHolderImage
                                         success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                             
                                             [weakCurrentImageView setImage:image];
                                             
                                         }
         
                                         failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                             NSLog(@"%@", [error localizedDescription]);
                                         }];
        
        
    }
    
    // *********$$$$$$$$ MAIN LOOP FOR ENDS HERE $$$$$$$****************
    
    
    /*-- PART 4. LAST PREPARATIONS, SETTING GLOBAL GALLERY INSETS, COLLAPSING UNUSED IMAGEVIEWS --
     */
    
    //  Setting top constraint for second row
    postCell.gallerySecondRowTopConstraint.constant = maxHeigthFirstRow + 12.f; // 12 = 8 + 4 - indents (see main.storyboard)
    
    //  For unused Gallery Image Views - setting widhts and heights to 0. Collapsing unused imageviews.
    for (int i = (int)[post.attachmentsArray count]; i < [postCell.photoWidths count]; i++) {
        
        NSLayoutConstraint* photoHightConstraint = [postCell.photoHeights objectAtIndex:i];
        photoHightConstraint.constant = 0.f;
        
        NSLayoutConstraint* photoWidthConstraint = [postCell.photoWidths objectAtIndex:i];
        photoWidthConstraint.constant = 0.f;
        
        UIImageView* unusedImageView = [postCell.glryImageViews objectAtIndex:i];
        
        unusedImageView.frame = CGRectMake(CGRectGetMinX(unusedImageView.frame),
                                           CGRectGetMinY(unusedImageView.frame),
                                           0.f, 0.f);
    }
    
    //  Centering Gallery
    
    CGFloat indentsCountFirstRow, indentsCountSecondRow;
    
    if ([post.attachmentsArray count] <= firstRowCount) {
        
        indentsCountFirstRow = [post.attachmentsArray count] - 1;
        
        postCell.gallerySecondRowLeadingConstraint.constant = 0;
        
    } else {
        
        indentsCountFirstRow = firstRowCount - 1;
        indentsCountSecondRow = [post.attachmentsArray count] - firstRowCount - 1;
        
        postCell.gallerySecondRowLeadingConstraint.constant = (self.tableViewWidth - 4 * indentsCountSecondRow - fullWidthSecondRow) / 2;
        
    }
    
    
    postCell.galleryFirstRowLeadingConstraint.constant = (self.tableViewWidth - 4 * indentsCountFirstRow - fullWidthFirstRow) / 2;
    
    
    
    
    [postCell layoutIfNeeded];
    
    /*
     ****************************************
     *      END OF SHOW IMAGES IN POST      *
     ****************************************
     */
    
    
    
    
    
}







@end
