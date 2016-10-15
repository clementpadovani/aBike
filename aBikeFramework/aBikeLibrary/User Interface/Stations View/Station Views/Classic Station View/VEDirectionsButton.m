//
//  VEDirectionsButton.m
//  aBike—Lyon
//
//  Created by Clément Padovani on 10/15/16.
//  Copyright (c) 2016 Clement Padovani. All rights reserved.
//

#import "VEDirectionsButton.h"

static const UIEdgeInsets kVEDirectionsButtonInsets = {14, 16, 14, 16};

@interface VEDirectionsButton ()

@end

@implementation VEDirectionsButton

+ (instancetype) directionsButton
{
    VEDirectionsButton *directionsButton = [self buttonWithType: UIButtonTypeCustom];
    
    [directionsButton setEnabled: NO];
    
    UIImage *directionsImage = [UIImage imageNamed: @"directionsIcon"
                                          inBundle: [NSBundle ve_libraryResources]
                     compatibleWithTraitCollection: nil];
    
    UIImage *disabledDirectionsImage = [UIImage imageNamed: @"noDirectionsIcon"
                                                  inBundle: [NSBundle ve_libraryResources]
                             compatibleWithTraitCollection: nil];
    
    UIImage *templateDirectionsImage = [directionsImage imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];
    
    
#if (SCREENSHOTS==1)
    
    [directionsButton setAccessibilityIdentifier: @"directionsIcon"];
    
#endif
    
    [directionsButton setImage: disabledDirectionsImage forState: UIControlStateDisabled];
    
    [directionsButton setImage: templateDirectionsImage forState: UIControlStateNormal];
    
    [directionsButton setImage: directionsImage forState: UIControlStateSelected];
    
    [directionsButton setContentEdgeInsets: kVEDirectionsButtonInsets];

    
    return directionsButton;
}

@end
