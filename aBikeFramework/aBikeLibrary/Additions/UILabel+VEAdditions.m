//
//  UILabel+VEAdditions.m
//  aBike—Lyon
//
//  Created by Clément Padovani on 9/10/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

#import "UILabel+VEAdditions.h"
@import ObjectiveC;

@implementation UILabel (VEAdditions)

+ (void) load
{
    [super load];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(init);
        SEL swizzledSelector = @selector(ve_init);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        // ...
        // Method originalMethod = class_getClassMethod(class, originalSelector);
        // Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (instancetype) ve_init
{
    UILabel *newInstance = [self ve_init];
    
    if ([newInstance respondsToSelector: @selector(setAdjustsFontForContentSizeCategory:)])
        [newInstance setAdjustsFontForContentSizeCategory: YES];
    
    return newInstance;
}

@end
