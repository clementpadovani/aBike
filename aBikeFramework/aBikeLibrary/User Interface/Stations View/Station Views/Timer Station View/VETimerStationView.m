//
//  VETimerStationView.m
//  aBike—Lyon
//
//  Created by Clément Padovani on 6/25/16.
//  Copyright (c) 2016 Clement Padovani. All rights reserved.
//

#import "VETimerStationView.h"

@import CoreText;
#import "NSBundle+VELibrary.h"

@interface VETimerStationView ()

@property (nonatomic, weak) UIButton *thirtyMinutesButton;

@property (nonatomic, weak) UIButton *hourButton;

@property (nonatomic, weak) UILabel *remainingTimeLabel;

@property (nonatomic, weak) UIButton *stopButton;

@property (nonatomic, assign) BOOL hasSetupConstraints;

@end

@implementation VETimerStationView

- (instancetype) init
{
	self = [super init];
	
	if (self)
	{
		[self setBackgroundColor: [UIColor clearColor]];
		
        [self setLayoutMargins: UIEdgeInsetsMake(15, 15, 15, 15)];
        
		[self setOpaque: NO];
		
		[self setTranslatesAutoresizingMaskIntoConstraints: NO];
		
		[self setupViews];
	}
	
	return self;
}

- (void) setupViews
{
    UIButton *thirtyMinutesButton = [UIButton buttonWithType: UIButtonTypeSystem];
    
    [thirtyMinutesButton setTitle: @"30" forState: UIControlStateNormal];
    
    [thirtyMinutesButton addTarget: self action: @selector(timeButtonSelected:) forControlEvents: UIControlEventTouchUpInside];
    
    [thirtyMinutesButton setTranslatesAutoresizingMaskIntoConstraints: NO];

    UIButton *hourButton = [UIButton buttonWithType: UIButtonTypeSystem];
    
    [hourButton setTitle: @"1h" forState: UIControlStateNormal];
    
    [hourButton addTarget: self action: @selector(timeButtonSelected:) forControlEvents: UIControlEventTouchUpInside];
    
    [hourButton setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    UILabel *remainingTimeLabel = [[UILabel alloc] init];
    
    [remainingTimeLabel setFont: [self timeRemainingFont]];
    
    [remainingTimeLabel setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    UIButton *stopButton = [UIButton buttonWithType: UIButtonTypeSystem];
    
    [stopButton addTarget: self action: @selector(stoppedPressed) forControlEvents: UIControlEventTouchUpInside];
    
    [stopButton setTitle: @"Stop" forState: UIControlStateNormal];
    
    [stopButton setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    [self addSubview: thirtyMinutesButton];
    
    [self addSubview: hourButton];
    
    [self addSubview: remainingTimeLabel];
    
    [self addSubview: stopButton];
    
    [self setThirtyMinutesButton: thirtyMinutesButton];
    
    [self setHourButton: hourButton];
    
    [self setRemainingTimeLabel: remainingTimeLabel];
    
    [self setStopButton: stopButton];
}

- (void) stoppedPressed
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (UIFont *) timeRemainingFont
{
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle: UIFontTextStyleBody];
    
    NSArray *fontFeatureSettings = @[@{UIFontFeatureTypeIdentifierKey: @(kNumberSpacingType),
                                    UIFontFeatureSelectorIdentifierKey: @(kProportionalNumbersSelector)}];
    
    NSDictionary *fontAttributes = @{UIFontDescriptorFeatureSettingsAttribute : fontFeatureSettings};
    
    fontDescriptor = [fontDescriptor fontDescriptorByAddingAttributes: fontAttributes];
    
    return [UIFont fontWithDescriptor: fontDescriptor size: 0];
}

- (void) timeButtonSelected: (UIButton *) button
{
    if ([button isEqual: [self thirtyMinutesButton]])
        [self scheduleTimeForDuration: 30. * 60.];
    else if ([button isEqual: [self hourButton]])
        [self scheduleTimeForDuration: 60. * 60.];
    else
        CPLog(@"UNKNOWN BUTTON: %@", button);
}

- (void) scheduleTimeForDuration: (NSTimeInterval) timerDuration
{
    NSDate *finalFireDate = [NSDate dateWithTimeIntervalSinceNow: timerDuration];
    
    // 5 mins prior
    NSDate *reminderFireDate = [NSDate dateWithTimeIntervalSinceNow: (timerDuration - (5. * 60.))];
    
    UILocalNotification *finalNotification = [[UILocalNotification alloc] init];
    
    [finalNotification setSoundName: UILocalNotificationDefaultSoundName];
    
    [finalNotification setFireDate: finalFireDate];
    
    [finalNotification setAlertTitle: [[NSBundle mainBundle] ve_applicationName]];
    
    [finalNotification setAlertBody: @"blabla"];
    
    UILocalNotification *reminderNotification = [[UILocalNotification alloc] init];
    
    [reminderNotification setSoundName: UILocalNotificationDefaultSoundName];
    
    [reminderNotification setFireDate: reminderFireDate];
    
    [reminderNotification setAlertTitle: [[NSBundle mainBundle] ve_applicationName]];
    
    [reminderNotification setAlertBody: @"blabla"];
    
    [[UIApplication sharedApplication] scheduleLocalNotification: finalNotification];
    
    [[UIApplication sharedApplication] scheduleLocalNotification: reminderNotification];
}

- (void) setupConstraints
{
	NSDictionary *viewsDictionary = <#views dictionary#>;
	
	NSDictionary *metricsDictionary = nil;
}

- (void) updateConstraints
{
	if (![self hasSetupConstraints])
	{
		[self setupConstraints];
		
		[self setHasSetupConstraints: YES];
	}
	
	[super updateConstraints];
}

+ (BOOL) requiresConstraintBasedLayout
{
	return YES;
}

@end
