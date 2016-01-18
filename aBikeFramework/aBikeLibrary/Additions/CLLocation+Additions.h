//
//  CLLocation+Additions.h
//  aBikeLibrary
//
//  Created by Clément Padovani on 7/12/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

@import CoreLocation.CLLocation;

NS_ASSUME_NONNULL_BEGIN

@interface CLLocation (Additions)

- (BOOL) ve_isCircaEqual: (CLLocation *) aLocation;

@end

NS_ASSUME_NONNULL_END
