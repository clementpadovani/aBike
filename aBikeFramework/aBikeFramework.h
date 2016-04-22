//
//  aBikeFramework.h
//  aBikeFramework
//
//  Created by Clément Padovani on 1/15/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for aBikeFramework.
FOUNDATION_EXPORT double aBikeFrameworkVersionNumber;

//! Project version string for aBikeFramework.
FOUNDATION_EXPORT const unsigned char aBikeFrameworkVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <aBikeFramework/PublicHeader.h>

//#import <aBikeFramework/VEConsulDefines.h>

@import CoreData;

@import CoreLocation;

@import MapKit;

#import <aBikeFramework/CLLocation+Additions.h>
#import <aBikeFramework/CPCoreDataManager.h>
#import <aBikeFramework/LightStation.h>
#import <aBikeFramework/NSBundle+VELibrary.h>
#import <aBikeFramework/NSNumber+Extensions.h>
#import <aBikeFramework/NSString+NumberOfLines.h>
#import <aBikeFramework/NSString+ProcessedStationName.h>
#import <aBikeFramework/Station+Additions.h>
#import <aBikeFramework/Station.h>
#import <aBikeFramework/UIAlertAction+VEAdditions.h>
#import <aBikeFramework/UIColor+MainColor.h>
#import <aBikeFramework/UIDevice+Additions.h>
#import <aBikeFramework/UIImage+VEImageAdditions.h>
#import <aBikeFramework/UserSettings+Additions.h>
#import <aBikeFramework/UserSettings.h>
#import <aBikeFramework/VEAlertControllerManager.h>
#import <aBikeFramework/VEAlertManager.h>
#import <aBikeFramework/VEBaseModel.h>
#import <aBikeFramework/VEConnectionManager.h>
#import <aBikeFramework/VEConsul.h>
#import <aBikeFramework/VEConsulDefines.h>
#import <aBikeFramework/VEDataImporter.h>
#import <aBikeFramework/VELocationManager.h>
#import <aBikeFramework/VEManagedObjectContext.h>
#import <aBikeFramework/VEMapContainerView.h>
#import <aBikeFramework/VEMapViewBlurImageView.h>
#import <aBikeFramework/VEMapViewController.h>
#import <aBikeFramework/VEReachability.h>
#import <aBikeFramework/VERouteRenderer.h>
#import <aBikeFramework/VESearchStationView.h>
#import <aBikeFramework/VEStationAnnotationAccessoryView.h>
#import <aBikeFramework/VEStationAnnotationDirectionsAccessoryView.h>
#import <aBikeFramework/VEStationAnnotationShareAccessoryView.h>
#import <aBikeFramework/VEStationAnnotationView.h>
#import <aBikeFramework/VEStationView.h>
#import <aBikeFramework/VEStationsScrollView.h>
#import <aBikeFramework/VEStationsView.h>
#import <aBikeFramework/VETimeFormatter.h>
#import <aBikeFramework/VEWindow.h>
