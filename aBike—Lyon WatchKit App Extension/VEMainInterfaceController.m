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

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceMap *stationMap;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *stationNameLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *availableBikesLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *availableStandsLabel;

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

- (void) willActivate
{
    [super willActivate];

    [[self stationMap] addAnnotation: [[[self currentBikeStation] stationLocation] coordinate]
                        withPinColor: WKInterfaceMapPinColorRed];

    [[self stationNameLabel] setText: [[self currentBikeStation] stationName]];

    [[self availableBikesLabel] setText: [NSString stringWithFormat: @"%lu", (unsigned long) [[self currentBikeStation] availableBikes]]];

    [[self availableStandsLabel] setText: [NSString stringWithFormat: @"%lu", (unsigned long) [[self currentBikeStation] availableStands]]];
}

@end



