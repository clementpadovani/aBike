//
//  NSBundle+VELibrary.h
//  aBikeLibrary
//
//  Created by Clément Padovani on 5/31/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

@import Foundation.NSBundle;

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (VELibrary)

+ (NSBundle *) ve_libraryResources;

+ (NSURL *) ve_fileURLForCities;

+ (NSString *) ve_adRemoverProductIdentifier;

@end

NS_ASSUME_NONNULL_END
