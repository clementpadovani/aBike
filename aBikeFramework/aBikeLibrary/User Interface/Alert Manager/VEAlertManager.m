//
//  VEAlertManager.m
//  abike—Lyon
//
//  Created by Clément Padovani on 4/26/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "VEAlertManager.h"

#import "VEAlertControllerManager.h"

@interface VEAlertManager ()

+ (void) ios8_showAlertOfType: (VEAlertType) alertType withConfigurationBlock: (VEAlertManagerConfigurationBlock) configurationBlock withHasSetupBlock: (VEAlertManagerHasSetupBlock) setupBlock withCompletionBlock: (VEAlertManagerCompletionBlock) completionBlock;

@end

@implementation VEAlertManager

+ (void) showAlertOfType: (VEAlertType) alertType withConfigurationBlock: (VEAlertManagerConfigurationBlock) configurationBlock withHasSetupBlock: (VEAlertManagerHasSetupBlock) setupBlock withCompletionBlock: (VEAlertManagerCompletionBlock) completionBlock
{
		[self ios8_showAlertOfType: alertType withConfigurationBlock: configurationBlock withHasSetupBlock: setupBlock withCompletionBlock: completionBlock];
}

+ (void) ios8_showAlertOfType: (VEAlertType) alertType withConfigurationBlock: (VEAlertManagerConfigurationBlock) configurationBlock withHasSetupBlock: (VEAlertManagerHasSetupBlock) setupBlock withCompletionBlock: (VEAlertManagerCompletionBlock) completionBlock
{
	VEAlertControllerManager *manager = [VEAlertControllerManager sharedManager];
	
	[manager showAlertOfType: alertType withConfigurationBlock: configurationBlock withHasSetupBlock: setupBlock withCompletionBlock: completionBlock];
}

@end
