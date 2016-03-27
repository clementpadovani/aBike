//
//  NSCoder+VEAdditions.m
//  aBike—Lyon
//
//  Created by Clément Padovani on 3/27/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

#import "NSCoder+VEAdditions.h"

@implementation NSCoder (VEAdditions)

- (void) ve_encodeUnsignedInteger: (NSUInteger) integer forKey: (NSString *) key
{
    [self encodeObject: [NSNumber numberWithUnsignedInteger: integer] forKey: key];
}

- (NSUInteger) ve_decodeUnsignedIntegerForKey: (NSString *) key
{
    return [[self decodeObjectForKey: key] unsignedIntegerValue];
}

@end
