//
//  ANPhotoAlbum.h
//  46_APIWithTokenHomework
//
//  Created by Anton Novoselov on 20/02/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

#import "ANServerObject.h"

@interface ANPhotoAlbum : ANServerObject

@property (strong, nonatomic) NSString* albumID;

@property (strong, nonatomic) NSString* albumTitle;

@property (strong, nonatomic) NSString* albumDescription;

@property (strong, nonatomic) NSString* albumSize;

@property (strong, nonatomic) NSURL* albumThumbImageURL;


@end
