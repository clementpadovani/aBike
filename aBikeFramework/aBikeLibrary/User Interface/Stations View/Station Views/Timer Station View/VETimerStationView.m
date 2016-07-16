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
#import "VETimerStationEnableNotificationsView.h"

static const NSTimeInterval kVETimerStationViewRemainingTimeTimerInterval = .5;

@interface VETimerStationView ()

@property (nonatomic, strong) NSDateComponentsFormatter *countdownFormatter;

@property (nonatomic, strong) NSDateComponentsFormatter *durationFormatter;

@property (nonatomic, weak) NSTimer *remainingTimeTimer;

@property (nonatomic, copy) NSDate *finalFireDate;

@property (nonatomic, weak) UILabel *timerHeaderLabel;

@property (nonatomic, weak) UIButton *thirtyMinutesButton;

@property (nonatomic, weak) UIButton *hourButton;

@property (nonatomic, weak) UILabel *remainingTimeLabel;

@property (nonatomic, weak) UIButton *stopButton;

@property (nonatomic, weak) VETimerStationEnableNotificationsView *notificationsView;

@property (nonatomic, assign) BOOL hasSetupConstraints;

@end

@implementation VETimerStationView

- (instancetype) init
{
	self = [super init];
	
	if (self)
	{
		[self setBackgroundColor: [UIColor clearColor]];
		
        [self setLayoutMargins: UIEdgeInsetsMake(15, 15, 40, 15)];
        
		[self setOpaque: NO];
		
		[self setTranslatesAutoresizingMaskIntoConstraints: NO];
		
        [self setupCountdownFormatter];
        
        [self setupDurationFormatter];
        
		[self setupViews];
        
        [self checkForNotifications];
	}
	
	return self;
}

- (void) setupCountdownFormatter
{
    NSDateComponentsFormatter *formatter = [[NSDateComponentsFormatter alloc] init];
    
    [formatter setUnitsStyle: NSDateComponentsFormatterUnitsStylePositional];
    
    [formatter setAllowedUnits: NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond];
    
    [formatter setZeroFormattingBehavior: NSDateComponentsFormatterZeroFormattingBehaviorPad];
    
    [self setCountdownFormatter: formatter];
}

- (void) setupDurationFormatter
{
    NSDateComponentsFormatter *formatter = [[NSDateComponentsFormatter alloc] init];
    
    [formatter setUnitsStyle: NSDateComponentsFormatterUnitsStyleAbbreviated];
    
    [formatter setAllowedUnits: NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond];
    
    [self setDurationFormatter: formatter];
}

- (void) checkForNotifications
{
    UIUserNotificationSettings *notifications = [[UIApplication sharedApplication] currentUserNotificationSettings];
    
    BOOL hideNotifications = ([notifications types] != UIUserNotificationTypeNone);
    
    [[self notificationsView] setHidden: hideNotifications];
    
    [[self thirtyMinutesButton] setHidden: !hideNotifications];
    
    [[self hourButton] setHidden: !hideNotifications];
    
    [[self remainingTimeLabel] setHidden: !hideNotifications];
    
    [[self stopButton] setHidden: !hideNotifications];
}

- (void) tintColorDidChange
{
    [super tintColorDidChange];
    
    [[self timerHeaderLabel] setTextColor: [self tintColor]];
    
    [[self remainingTimeLabel] setTextColor: [self tintColor]];
}

- (void) setupViews
{
    UILabel *timerHeaderLabel = [[UILabel alloc] init];
    
    [timerHeaderLabel setTextAlignment: NSTextAlignmentCenter];
    
    [timerHeaderLabel setText: CPLocalizedString(@"Timer", nil)];
    
    [timerHeaderLabel setTextColor: [self tintColor]];
    
    [timerHeaderLabel setFont: [UIFont preferredFontForTextStyle: UIFontTextStyleHeadline]];
    
    [timerHeaderLabel setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    UIButton *thirtyMinutesButton = [UIButton buttonWithType: UIButtonTypeSystem];
    
    NSString *localizedThirtyMinutes = [[self durationFormatter] stringFromTimeInterval: 30. * 60.];
    
    [thirtyMinutesButton setTitle: localizedThirtyMinutes forState: UIControlStateNormal];
    
    [thirtyMinutesButton addTarget: self action: @selector(timeButtonSelected:) forControlEvents: UIControlEventTouchUpInside];
    
    [thirtyMinutesButton setTranslatesAutoresizingMaskIntoConstraints: NO];

    UIButton *hourButton = [UIButton buttonWithType: UIButtonTypeSystem];
    
    NSString *localizedHour = [[self durationFormatter] stringFromTimeInterval: 60. * 60.];
    
    [hourButton setTitle: localizedHour forState: UIControlStateNormal];
    
    [hourButton addTarget: self action: @selector(timeButtonSelected:) forControlEvents: UIControlEventTouchUpInside];
    
    [hourButton setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    UILabel *remainingTimeLabel = [[UILabel alloc] init];
    
    [remainingTimeLabel setTextAlignment: NSTextAlignmentCenter];
    
    [remainingTimeLabel setContentMode: UIViewContentModeCenter];
    
    if ([remainingTimeLabel respondsToSelector: @selector(setAllowsDefaultTighteningForTruncation:)])
        [remainingTimeLabel setAllowsDefaultTighteningForTruncation: YES];
    
    [remainingTimeLabel setTextColor: [self tintColor]];
    
    [remainingTimeLabel setFont: [self timeRemainingFont]];
    
    [remainingTimeLabel setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    UIButton *stopButton = [UIButton buttonWithType: UIButtonTypeSystem];
    
    [stopButton addTarget: self action: @selector(stoppedPressed) forControlEvents: UIControlEventTouchUpInside];
    
    [stopButton setTitle: CPLocalizedString(@"Stop", nil) forState: UIControlStateNormal];
    
    [stopButton setSelected: NO];
    
    [stopButton setEnabled: NO];
    
    [stopButton setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    VETimerStationEnableNotificationsView *notificationsView = [[VETimerStationEnableNotificationsView alloc] init];
    
    [self addSubview: timerHeaderLabel];
    
    [self addSubview: thirtyMinutesButton];
    
    [self addSubview: hourButton];
    
    [self addSubview: remainingTimeLabel];
    
    [self addSubview: stopButton];
    
    [self addSubview: notificationsView];
    
    [self setTimerHeaderLabel: timerHeaderLabel];
    
    [self setThirtyMinutesButton: thirtyMinutesButton];
    
    [self setHourButton: hourButton];
    
    [self setRemainingTimeLabel: remainingTimeLabel];
    
    [self setStopButton: stopButton];
    
    [self setNotificationsView: notificationsView];
}

- (void) stoppedPressed
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    [[self remainingTimeTimer] invalidate];
    
    [self setFinalFireDate: nil];
    
    [[self remainingTimeLabel] setText: nil];
    
    [[self stopButton] setEnabled: NO];
    
    [[self stopButton] setSelected: NO];
    
    [[self thirtyMinutesButton] setEnabled: YES];
    
    [[self hourButton] setEnabled: YES];
}

- (UIFont *) timeRemainingFont
{
    UIFont *font = [UIFont preferredFontForTextStyle: UIFontTextStyleBody];
    
    UIFontDescriptor *fontDescriptor = [font fontDescriptor];
    
    NSArray *fontFeatureSettings = @[@{UIFontFeatureTypeIdentifierKey: @(kNumberSpacingType),
                                    UIFontFeatureSelectorIdentifierKey: @(kProportionalNumbersSelector)},
                                     @{UIFontFeatureTypeIdentifierKey: @(kCharacterAlternativesType),
                                       UIFontFeatureSelectorIdentifierKey: @(1)}];
    
    NSDictionary *fontAttributes = @{UIFontDescriptorFeatureSettingsAttribute : fontFeatureSettings};
    
    fontDescriptor = [fontDescriptor fontDescriptorByAddingAttributes: fontAttributes];
    
    UIFont *theFont = [UIFont fontWithDescriptor: fontDescriptor size: 0];
    
    return theFont;
}

- (void) notifications_applicationDidBecomeActive: (NSNotification *) notification
{
    [self checkForNotifications];
    
    [self performSelectorOnMainThread: @selector(checkForNotifications) withObject: nil waitUntilDone: NO];
}

- (void) stationViewDidAppear
{
    [self checkForNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(notifications_applicationDidBecomeActive:)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
}

- (void) stationViewDidDisappear
{
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIApplicationDidBecomeActiveNotification
                                                  object: nil];
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
#if DEBUG == 1
    
    timerDuration /= 60.;
    
#endif
    
    [[self stopButton] setEnabled: YES];
    
    [[self stopButton] setSelected: YES];
    
    [[self thirtyMinutesButton] setEnabled: NO];
    
    [[self hourButton] setEnabled: NO];
    
    [[self remainingTimeTimer] invalidate];
    
    NSDate *finalFireDate = [NSDate dateWithTimeIntervalSinceNow: timerDuration];
    
    [self setFinalFireDate: finalFireDate];
    
    NSTimer *remainingTimeTimer = [NSTimer timerWithTimeInterval: kVETimerStationViewRemainingTimeTimerInterval
                                                          target: self
                                                        selector: @selector(remainingTimerDidFire:)
                                                        userInfo: nil
                                                         repeats: YES];
    
    [[NSRunLoop currentRunLoop] addTimer: remainingTimeTimer
                                 forMode: NSRunLoopCommonModes];
    
    [[NSRunLoop currentRunLoop] addTimer: remainingTimeTimer
                                 forMode: UITrackingRunLoopMode];
    
    [self setRemainingTimeTimer: remainingTimeTimer];
    
    [self updateRemainingTimeForRemainingDuration: timerDuration];
    
    // 5 mins prior
    NSDate *reminderFireDate = [NSDate dateWithTimeIntervalSinceNow: (timerDuration - (5. * 60.))];
    
    UILocalNotification *finalNotification = [[UILocalNotification alloc] init];
    
    [finalNotification setSoundName: UILocalNotificationDefaultSoundName];
    
    [finalNotification setFireDate: finalFireDate];
    
    [finalNotification setAlertTitle: [[NSBundle mainBundle] ve_applicationName]];
    
    NSString *localizedDuration = [[self durationFormatter] stringFromTimeInterval: timerDuration];
    
    NSString *finalNotificationText = [NSString localizedStringWithFormat: CPLocalizedString(@"The free %@ are over!", nil), localizedDuration];
    
    [finalNotification setAlertBody: finalNotificationText];
    
    UILocalNotification *reminderNotification = [[UILocalNotification alloc] init];
    
    [reminderNotification setSoundName: UILocalNotificationDefaultSoundName];
    
    [reminderNotification setFireDate: reminderFireDate];
    
    [reminderNotification setAlertTitle: [[NSBundle mainBundle] ve_applicationName]];

    NSString *reminderDuration = [[self durationFormatter] stringFromTimeInterval: 5. * 60.];
    
    NSString *reminderNotificationText = [NSString localizedStringWithFormat: CPLocalizedString(@"The free %@ are almost over, only %@ left!", nil), localizedDuration, reminderDuration];
    
    [reminderNotification setAlertBody: reminderNotificationText];
    
    [[UIApplication sharedApplication] scheduleLocalNotification: finalNotification];
    
    [[UIApplication sharedApplication] scheduleLocalNotification: reminderNotification];
}

- (void) remainingTimerDidFire: (NSTimer *) timer
{
    NSTimeInterval remainingTime = [[self finalFireDate] timeIntervalSinceNow];
    
    remainingTime = ceil(remainingTime);
    
    if (remainingTime < 0)
    {
        [timer invalidate];
        
        [self setRemainingTimeTimer: nil];
        
        [self setFinalFireDate: nil];
        
        remainingTime = 0;
    }
    
    [self updateRemainingTimeForRemainingDuration: remainingTime];
}

- (void) updateRemainingTimeForRemainingDuration: (NSTimeInterval) remainingDuration
{
    NSString *remainingTimeString = [[self countdownFormatter] stringFromTimeInterval: remainingDuration];
    
    [[self remainingTimeLabel] setText: remainingTimeString];
}

- (void) setupConstraints
{
	NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_timerHeaderLabel,
                                                                   _thirtyMinutesButton,
                                                                   _hourButton,
                                                                   _remainingTimeLabel,
                                                                   _stopButton,
                                                                   _notificationsView);
	
	NSDictionary *metricsDictionary = nil;
    
    [self addConstraint: [NSLayoutConstraint constraintWithItem: [self timerHeaderLabel]
                                                      attribute: NSLayoutAttributeCenterX
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeCenterX
                                                     multiplier: 1
                                                       constant: 0]];
    
    [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-[_hourButton][_remainingTimeLabel][_stopButton]-|"
                                                                  options: NSLayoutFormatAlignAllBottom
                                                                  metrics: metricsDictionary
                                                                    views: viewsDictionary]];
    
    [self addConstraint: [NSLayoutConstraint constraintWithItem: [self remainingTimeLabel]
                                                      attribute: NSLayoutAttributeCenterX
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: self
                                                      attribute: NSLayoutAttributeCenterX
                                                     multiplier: 1
                                                       constant: 0]];
    
    [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:[_thirtyMinutesButton]-[_hourButton]"
                                                                  options: NSLayoutFormatAlignAllCenterX
                                                                  metrics: metricsDictionary
                                                                    views: viewsDictionary]];
    
    [self addConstraint: [NSLayoutConstraint constraintWithItem: [self thirtyMinutesButton]
                                                      attribute: NSLayoutAttributeWidth
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: [self hourButton]
                                                      attribute: NSLayoutAttributeWidth
                                                     multiplier: 1
                                                       constant: 0]];
    
    [self addConstraint: [NSLayoutConstraint constraintWithItem: [self hourButton]
                                                      attribute: NSLayoutAttributeWidth
                                                      relatedBy: NSLayoutRelationEqual
                                                         toItem: [self thirtyMinutesButton]
                                                      attribute: NSLayoutAttributeWidth
                                                     multiplier: 1
                                                       constant: 0]];
    
    [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-(>=0)-[_remainingTimeLabel]-|"
                                                                  options: 0
                                                                  metrics: metricsDictionary
                                                                    views: viewsDictionary]];
    
    [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-[_notificationsView]-|"
                                                                  options: 0
                                                                  metrics: metricsDictionary
                                                                    views: viewsDictionary]];
    
    [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[_timerHeaderLabel][_notificationsView]-|"
                                                                  options: 0
                                                                  metrics: metricsDictionary
                                                                    views: viewsDictionary]];
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
