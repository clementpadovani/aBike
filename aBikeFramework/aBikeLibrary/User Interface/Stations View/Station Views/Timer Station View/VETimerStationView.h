//
//  VETimerStationView.h
//  aBike—Lyon
//
//  Created by Clément Padovani on 6/25/16.
//  Copyright (c) 2016 Clement Padovani. All rights reserved.
//

@import UIKit;
#import "VEStationViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface VETimerStationView : UIView <VEStationView>

- (instancetype) initWithFrame: (CGRect) frame NS_UNAVAILABLE;

- (instancetype) initWithCoder: (NSCoder *) aDecoder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
