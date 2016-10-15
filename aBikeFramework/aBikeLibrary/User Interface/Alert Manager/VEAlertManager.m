//
//  VEAlertManager.m
//  abike—Lyon
//
//  Created by Clément Padovani on 4/26/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "VEAlertManager.h"

#import "VEAlertControllerManager.h"

static UINotificationFeedbackGenerator *_feedbackGenerator = nil;

@interface VEAlertManager ()

@property (class, nonatomic, strong, readonly) UINotificationFeedbackGenerator *feedbackGenerator;

+ (void) ios8_showAlertOfType: (VEAlertType) alertType withConfigurationBlock: (VEAlertManagerConfigurationBlock) configurationBlock withHasSetupBlock: (VEAlertManagerHasSetupBlock) setupBlock withCompletionBlock: (VEAlertManagerCompletionBlock) completionBlock;

@end

@implementation VEAlertManager

+ (UINotificationFeedbackGenerator *) feedbackGenerator
{
    if (!_feedbackGenerator)
    {
        UINotificationFeedbackGenerator *feedbackGenerator = [[UINotificationFeedbackGenerator alloc] init];
        
        [feedbackGenerator prepare];
        
        _feedbackGenerator = feedbackGenerator;
    }
    
    return _feedbackGenerator;
}

+ (void) showAlertOfType: (VEAlertType) alertType withNotificationType: (UINotificationFeedbackType) feedbackType withConfigurationBlock: (VEAlertManagerConfigurationBlock) configurationBlock withHasSetupBlock: (VEAlertManagerHasSetupBlock) setupBlock withCompletionBlock: (VEAlertManagerCompletionBlock) completionBlock
{
    [[self feedbackGenerator] notificationOccurred: feedbackType];
    
    [self ios8_showAlertOfType: alertType withConfigurationBlock: configurationBlock withHasSetupBlock: setupBlock withCompletionBlock: completionBlock];
}

+ (void) ios8_showAlertOfType: (VEAlertType) alertType withConfigurationBlock: (VEAlertManagerConfigurationBlock) configurationBlock withHasSetupBlock: (VEAlertManagerHasSetupBlock) setupBlock withCompletionBlock: (VEAlertManagerCompletionBlock) completionBlock
{
	VEAlertControllerManager *manager = [VEAlertControllerManager sharedManager];
	
	[manager showAlertOfType: alertType withConfigurationBlock: configurationBlock withHasSetupBlock: setupBlock withCompletionBlock: completionBlock];
}

@end
