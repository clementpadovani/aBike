//
//  NSString+NumberOfLines.h
//  Velo'v
//
//  Created by Clément Padovani on 12/14/13.
//  Copyright (c) 2013 Clément Padovani. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@interface NSString (NumberOfLines)

@property (nonatomic, assign, readonly) NSUInteger ve_numberOfLines;

@property (nonatomic, assign, readonly) NSRange ve_stringRange;

//- (NSUInteger) numberOfLines;

- (NSString * __nullable) ve_substringAtLine: (NSUInteger) lineNumber;

- (NSRange) ve_rangeOfSubstringAtLine: (NSUInteger) lineNumber;

//- (NSRange) stringRange;

@end

NS_ASSUME_NONNULL_END
