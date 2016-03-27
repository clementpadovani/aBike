//
//  VEMainInterfaceController.m
//  aBike—Lyon
//
//  Created by Clément Padovani on 3/27/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

#import "VEMainInterfaceController.h"
#import "VEWatchBikeStation.h"
@import CoreLocation;

@interface VEMainInterfaceController ()

@property (nonatomic, strong) VEWatchBikeStation *currentBikeStation;

@property (weak, nonatomic) IBOutlet WKInterfaceMap *stationMap;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *stationNameLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *availableBikesLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *availableStandsLabel;

@end

@implementation VEMainInterfaceController

- (void) awakeWithContext: (id) context
{
    [super awakeWithContext: context];

    if ([context isKindOfClass: [VEWatchBikeStation class]])
    {
        [self setCurrentBikeStation: context];
    }
}

- (void) didAppear
{
    [super didAppear];

    CLLocationCoordinate2D location = [[[self currentBikeStation] stationLocation] coordinate];

    CLLocationDegrees scalingFactor = ABS((cos(2 * M_PI * location.latitude / 360.0)));

    static CLLocationDistance distance = 1000.;

    MKCoordinateSpan span = MKCoordinateSpanMake(distance / 111., distance / (scalingFactor * 111.));

    MKCoordinateRegion region = MKCoordinateRegionMake(location, span);

    [[self stationMap] setRegion: region];

    [[self stationMap] addAnnotation: location
                        withPinColor: WKInterfaceMapPinColorRed];

    [[self stationNameLabel] setText: [[self currentBikeStation] stationName]];

    [[self availableBikesLabel] setText: [NSString stringWithFormat: @"%lu", (unsigned long) [[self currentBikeStation] availableBikes]]];

    [[self availableStandsLabel] setText: [NSString stringWithFormat: @"%lu", (unsigned long) [[self currentBikeStation] availableStands]]];
}

@end



