//
//  WCSession+VEStateAdditions.m
//  aBike—Lyon
//
//  Created by Clément Padovani on 4/30/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

#import "WCSession+VEStateAdditions.h"

@implementation WCSession (VEStateAdditions)

- (BOOL) ve_sessionActive
{
    if ([self respondsToSelector: @selector(activationState)])
    {
        return [self activationState] == WCSessionActivationStateActivated;
    }
    else
    {
        return [self isPaired] && [self isWatchAppInstalled];
    }
}

@end
