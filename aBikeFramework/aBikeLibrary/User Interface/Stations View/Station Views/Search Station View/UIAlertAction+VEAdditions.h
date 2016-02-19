//
//  UIAlertAction+VEAdditions.h
//  aBike—Lyon
//
//  Created by Clément Padovani on 2/20/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

@import UIKit;

@import MapKit.MKMapItem;

@interface UIAlertAction (VEAdditions)

@property (nonatomic, strong, setter = ve_setMapItem:) MKMapItem *ve_mapItem;

@end
