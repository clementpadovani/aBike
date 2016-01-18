//
//  VEMKPlacemarkValueTransformer.m
//  abike—Lyon
//
//  Created by Clément Padovani on 3/30/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "VEMKPlacemarkValueTransformer.h"

@implementation VEMKPlacemarkValueTransformer

+ (Class) transformedValueClass
{
	return [NSData class];
}

+ (BOOL) allowsReverseTransformation
{
	return YES;
}

- (id) transformedValue: (id) value
{
	return [NSKeyedArchiver archivedDataWithRootObject: value];
}

- (id) reverseTransformedValue: (id) value
{
	return [NSKeyedUnarchiver unarchiveObjectWithData: value];
}

@end
