//
//  VEConnectionManager.h
//  Velo'v
//
//  Created by Clément Padovani on 10/24/13.
//  Copyright (c) 2013 Clément Padovani. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@interface VEConnectionManager : NSObject

@property (nonatomic, readonly, getter = isReachable) BOOL reachable;

@property (nonatomic) BOOL canCallBack;

+ (VEConnectionManager *) sharedConnectionManger;

+ (void) tearDownConnectionManager;

@end

NS_ASSUME_NONNULL_END
