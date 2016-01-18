//
//  VEStationAnnotationShareAccessoryView.m
//  aBikeLibrary
//
//  Created by Clément Padovani on 9/20/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "VEStationAnnotationShareAccessoryView.h"

static const UIEdgeInsets kContentInsets = {0, 0, 0, 0};

@implementation VEStationAnnotationShareAccessoryView

+ (instancetype) accessoryView
{
	VEStationAnnotationShareAccessoryView *accessoryView = [super accessoryView];
	
	if (accessoryView)
	{
		UIImage *sharingIcon = [UIImage imageNamed: @"sharing_icon"
								    inBundle: [NSBundle ve_libraryResources] compatibleWithTraitCollection: nil];
		
		[accessoryView setImage: [sharingIcon imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate] forState: UIControlStateNormal];
		
		[accessoryView setImage: [sharingIcon imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal] forState: UIControlStateSelected];
		
		[accessoryView setContentEdgeInsets: kContentInsets];
		
		[accessoryView sizeToFit];
	}
	
	return accessoryView;
}

@end
