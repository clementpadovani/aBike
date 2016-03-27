//
//  NSCoder+VEAdditions.h
//  aBike—Lyon
//
//  Created by Clément Padovani on 3/27/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSCoder (VEAdditions)

- (void) ve_encodeUnsignedInteger: (NSUInteger) integer forKey: (NSString *) key;

- (NSUInteger) ve_decodeUnsignedIntegerForKey: (NSString *) key;

@end

NS_ASSUME_NONNULL_END
