//
//  UIAlertAction+VEAdditions.m
//  aBike—Lyon
//
//  Created by Clément Padovani on 2/20/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

#import "UIAlertAction+VEAdditions.h"

@import ObjectiveC.runtime;

static NSString * const ve_mapItemKey = @"ve_mapItemKey";

@implementation UIAlertAction (VEAdditions)

@dynamic ve_mapItem;

- (void) ve_setMapItem: (MKMapItem *) ve_mapItem
{
	objc_setAssociatedObject(self, &ve_mapItemKey, ve_mapItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MKMapItem *) ve_mapItem
{
	return objc_getAssociatedObject(self, &ve_mapItemKey);
}

@end
