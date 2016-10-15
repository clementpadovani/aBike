//
//  VEDirectionsButton.h
//  aBike—Lyon
//
//  Created by Clément Padovani on 10/15/16.
//  Copyright (c) 2016 Clement Padovani. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface VEDirectionsButton : UIButton

+ (instancetype) directionsButton;

- (instancetype) initWithFrame: (CGRect) frame NS_UNAVAILABLE;

- (instancetype) initWithCoder: (NSCoder *) aDecoder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
