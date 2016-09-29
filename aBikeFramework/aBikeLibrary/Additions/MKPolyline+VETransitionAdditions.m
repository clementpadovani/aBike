//
//  MKPolyline+VETransitionAdditions.m
//  aBike—Lyon
//
//  Created by Clément Padovani on 9/29/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

#import "MKPolyline+VETransitionAdditions.h"
@import ObjectiveC;

@implementation MKPolyline (VETransitionAdditions)

@dynamic ve_transitionProgress;

- (CGFloat) ve_transitionProgress
{
    NSNumber *transitionProgressNumber = objc_getAssociatedObject(self, @selector(ve_transitionProgress));
    
    CGFloat transitionProgress;
    
#if CGFLOAT_IS_DOUBLE
    transitionProgress = [transitionProgressNumber doubleValue];
#else
    transitionProgress = [transitionProgressNumber floatValue];
#endif
    return transitionProgress;
}

- (void) ve_setTransitionProgress: (CGFloat) ve_transitionProgress
{
    objc_setAssociatedObject(self, @selector(ve_transitionProgress), @(ve_transitionProgress), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
