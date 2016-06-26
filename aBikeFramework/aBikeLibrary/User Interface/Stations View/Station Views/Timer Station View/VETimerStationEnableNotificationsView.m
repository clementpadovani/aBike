//
//  VETimerStationEnableNotificationsView.m
//  aBike—Lyon
//
//  Created by Clément Padovani on 6/26/16.
//  Copyright (c) 2016 Clement Padovani. All rights reserved.
//

#import "VETimerStationEnableNotificationsView.h"
#import "NSBundle+VELibrary.h"
#import "VEConsul.h"
#import "VEMapViewController.h"

static NSString * const kVETimerStationEnableNotificationsViewHasRegisteredForNotifications = @"kVETimerStationEnableNotificationsViewHasRegisteredForNotifications";

@interface VETimerStationEnableNotificationsView ()

@property (nonatomic, weak) UILabel *authorizationLabel;

@property (nonatomic, weak) UIButton *authorizationButton;

@property (nonatomic, assign) BOOL hasSetupConstraints;

@end

@implementation VETimerStationEnableNotificationsView

- (instancetype) init
{
	self = [super init];
	
	if (self)
	{
		[self setBackgroundColor: [UIColor clearColor]];
		
		[self setOpaque: NO];
		
		[self setTranslatesAutoresizingMaskIntoConstraints: NO];
		
		[self setupViews];
	}
	
	return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [[self authorizationLabel] setPreferredMaxLayoutWidth: CGRectGetWidth([[self authorizationLabel] bounds])];
}

- (void) setupViews
{
    UILabel *authorizationLabel = [[UILabel alloc] init];
    
    [authorizationLabel setTextColor: [self tintColor]];
    
    NSString *authorizationText = CPLocalizedString(@"Enable to receive alerts when your free ride is almost over", nil);
    
    [authorizationLabel setFont: [UIFont preferredFontForTextStyle: UIFontTextStyleBody]];
    
    [authorizationLabel setText: authorizationText];
    
    [authorizationLabel setNumberOfLines: 0];
    
    [authorizationLabel setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    UIButton *authorizationButton = [UIButton buttonWithType: UIButtonTypeSystem];
    
    [authorizationButton setTitle: CPLocalizedString(@"Enable Alerts", nil) forState: UIControlStateNormal];
    
    [authorizationButton addTarget: self action: @selector(enableNotifications) forControlEvents: UIControlEventTouchUpInside];
    
    [authorizationButton setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    [self addSubview: authorizationLabel];
    
    [self addSubview: authorizationButton];
    
    [self setAuthorizationLabel: authorizationLabel];
    
    [self setAuthorizationButton: authorizationButton];
}

- (void) enableNotifications
{
    NSString *alertMessage = CPLocalizedString(@"Enable Alerts for the ride timer", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: [[NSBundle mainBundle] ve_applicationName]
                                                                             message: alertMessage
                                                                      preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle: CPLocalizedString(@"Cancel", nil)
                                                           style: UIAlertActionStyleCancel
                                                         handler: NULL];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle: CPLocalizedString(@"Enable", nil)
                                                        style: UIAlertActionStyleDefault
                                                      handler: ^(UIAlertAction * _Nonnull action) {
                                                          
                                                          [self registerForNotifications];
                                                          
                                                      }];
    
    [alertController addAction: cancelAction];
    
    [alertController addAction: yesAction];
    
    if ([alertController respondsToSelector: @selector(setPreferredAction:)])
        [alertController setPreferredAction: yesAction];
    
    UIViewController *topViewController = [[VEConsul sharedConsul] mapViewController];
    
    [topViewController presentViewController: alertController animated: YES completion: NULL];
}

- (void) registerForNotifications
{
    BOOL hasAlreadyRegistered = [[NSUserDefaults standardUserDefaults] boolForKey: kVETimerStationEnableNotificationsViewHasRegisteredForNotifications];
    
    if (!hasAlreadyRegistered)
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes: UIUserNotificationTypeAlert | UIUserNotificationTypeSound
                                                                                 categories: nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings: settings];
            
        [[NSUserDefaults standardUserDefaults] setBool: YES forKey: kVETimerStationEnableNotificationsViewHasRegisteredForNotifications];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [[UIApplication sharedApplication] openURL: (NSURL * __nonnull) [NSURL URLWithString: UIApplicationOpenSettingsURLString]];
    }
}

- (void) setupConstraints
{
	NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_authorizationLabel,
                                                                   _authorizationButton);
	
	NSDictionary *metricsDictionary = nil;
    
    [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[_authorizationLabel]|"
                                                                  options: 0
                                                                  metrics: metricsDictionary
                                                                    views: viewsDictionary]];
    
    [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[_authorizationLabel]-[_authorizationButton]|"
                                                                  options: NSLayoutFormatAlignAllCenterX
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
