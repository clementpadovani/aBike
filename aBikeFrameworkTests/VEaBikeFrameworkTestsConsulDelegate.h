//
//  VEaBikeFrameworkTestsConsulDelegate.h
//  aBike—Lyon
//
//  Created by Clément Padovani on 3/12/16.
//  Copyright (c) 2016 Clement Padovani. All rights reserved.
//

@import Foundation;

@import aBikeFramework;

NS_ASSUME_NONNULL_BEGIN

@interface VEaBikeFrameworkTestsConsulDelegate : NSObject <VEConsulDelegate>

+ (VEaBikeFrameworkTestsConsulDelegate *) sharedDelegate;

@end

NS_ASSUME_NONNULL_END
