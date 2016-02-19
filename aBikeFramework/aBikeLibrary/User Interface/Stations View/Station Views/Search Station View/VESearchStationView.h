//
//  VESearchStationView.h
//  aBike—Lyon
//
//  Created by Clément Padovani on 2/19/16.
//  Copyright (c) 2016 Clement Padovani. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface VESearchStationView : UIView

@property (nonatomic, assign, getter = isVisible) BOOL visible;

- (instancetype) initWithFrame: (CGRect) frame NS_UNAVAILABLE;

- (instancetype) initWithCoder: (NSCoder *) aDecoder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
