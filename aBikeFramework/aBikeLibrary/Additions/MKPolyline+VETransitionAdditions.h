//
//  MKPolyline+VETransitionAdditions.h
//  aBike—Lyon
//
//  Created by Clément Padovani on 9/29/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

@import MapKit;

@interface MKPolyline (VETransitionAdditions)

@property (nonatomic, assign, setter = ve_setTransitionProgress:) CGFloat ve_transitionProgress;

@property (nonatomic, assign, setter = ve_setHasFullyShown:) BOOL ve_hasFullyShown;

@end
