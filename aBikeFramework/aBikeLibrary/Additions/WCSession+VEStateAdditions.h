//
//  WCSession+VEStateAdditions.h
//  aBike—Lyon
//
//  Created by Clément Padovani on 4/30/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

@import WatchConnectivity;

@interface WCSession (VEStateAdditions)

- (BOOL) ve_sessionActive;

@end
