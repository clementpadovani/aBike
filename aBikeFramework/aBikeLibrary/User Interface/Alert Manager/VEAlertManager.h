//
//  VEAlertManager.h
//  abike—Lyon
//
//  Created by Clément Padovani on 4/26/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

typedef NS_ENUM(NSUInteger, VEAlertStringType) {
	VEAlertStringTypeTitle = 0,
	VEAlertStringTypeMessage,
	VEAlertStringTypeCancelButtonTitle,
	VEAlertStringTypeActionButtonTitle
};

typedef NS_ENUM(NSUInteger, VEAlertType) {
	VEAlertTypeNoButtons = 0,
	VEAlertTypeWithButtons,
	VEAlertTypeWithAction
};

typedef NS_ENUM(NSUInteger, VEAlertButtonType) {
 
	VEAlertButtonTypeCancel = 0,
	VEAlertButtonTypeOther
};

typedef NSString * (^VEAlertManagerConfigurationBlock) (VEAlertStringType alertStringType);

typedef void (^VEAlertManagerCompletionBlock) (VEAlertButtonType buttonType);

typedef void (^VEAlertManagerHasSetupBlock) (id alertView);

@interface VEAlertManager : NSObject

+ (void) showAlertOfType: (VEAlertType) alertType withConfigurationBlock: (VEAlertManagerConfigurationBlock) configurationBlock withHasSetupBlock: (VEAlertManagerHasSetupBlock) setupBlock withCompletionBlock: (VEAlertManagerCompletionBlock) completionBlock;

@end
