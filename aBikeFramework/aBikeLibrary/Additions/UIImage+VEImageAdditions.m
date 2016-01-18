//
//  UIImage+VEImageAdditions.m
//  aBike—Lyon
//
//  Created by Clément Padovani on 1/17/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

#import "UIImage+VEImageAdditions.h"

@implementation UIImage (VEImageAdditions)

+ (nullable UIImage *) ve_imageNamed: (NSString *) name
{
	UIImage *image = [self imageNamed: name];

	if (!image)
		image = [self imageNamed: name
					 inBundle: [NSBundle ve_libraryResources]
	compatibleWithTraitCollection: nil];

	return image;
}

@end
