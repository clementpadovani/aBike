//
//  VEAlertControllerManager.m
//  aBikeLibrary
//
//  Created by Clément Padovani on 9/10/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "VEAlertControllerManager.h"

#import "VEConsul.h"

@interface VEAlertControllerManager ()

@property (nonatomic, weak) UIAlertController *alertController;

@end

@implementation VEAlertControllerManager

+ (VEAlertControllerManager *) sharedManager
{
	static VEAlertControllerManager *_sharedManager = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedManager = [[self alloc] init];
	});
	
	return _sharedManager;
}

- (void) showAlertOfType: (VEAlertType) alertType withConfigurationBlock: (VEAlertManagerConfigurationBlock) configurationBlock withHasSetupBlock: (VEAlertManagerHasSetupBlock) setupBlock withCompletionBlock: (VEAlertManagerCompletionBlock) completionBlock
{
	NSString *titleString = configurationBlock(VEAlertStringTypeTitle) ?: @"";
	
	NSString *messageString = configurationBlock(VEAlertStringTypeMessage);
	
	NSString *cancelButtonTitle = nil;
	
	NSString *actionButtonTitle = nil;
	
	if (alertType == VEAlertTypeWithButtons)
	{
		cancelButtonTitle = configurationBlock(VEAlertStringTypeCancelButtonTitle) ?: CPLocalizedString(@"Okay", @"alertView_cancelButton_okay");
	}
	else if (alertType == VEAlertTypeWithAction)
	{
		cancelButtonTitle = configurationBlock(VEAlertStringTypeCancelButtonTitle) ?: CPLocalizedString(@"Okay", @"alertView_cancelButton_okay");
		
		actionButtonTitle = configurationBlock(VEAlertStringTypeActionButtonTitle);
	}
	
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle: titleString
															   message: messageString
														 preferredStyle: UIAlertControllerStyleAlert];
	
	void (^actionBlock)(UIAlertAction *action) = ^(UIAlertAction *action) {
	
		//CPLog(@"an action: %@", action);
		
		BOOL isCancel = [action style] == UIAlertActionStyleCancel;

		if (completionBlock)
			completionBlock(isCancel ? VEAlertButtonTypeCancel : VEAlertButtonTypeOther);
		
		[(UIViewController *) [[VEConsul sharedConsul] mapViewController] dismissViewControllerAnimated: YES completion: NULL];
		
	};
	
	if (cancelButtonTitle)
	{
		UIAlertAction *cancelAction = [UIAlertAction actionWithTitle: cancelButtonTitle
													style: actionButtonTitle ? UIAlertActionStyleCancel : UIAlertActionStyleDefault
												   handler: actionBlock];
		
		[alertController addAction: cancelAction];
	}
	
	if (actionButtonTitle)
	{
		UIAlertAction *actionAction = [UIAlertAction actionWithTitle: actionButtonTitle
													style: UIAlertActionStyleDefault
												   handler: actionBlock];
		
		[alertController addAction: actionAction];
	}
	
	__weak UIAlertController *weakAlertController = alertController;
	
	[(UIViewController *) [[VEConsul sharedConsul] mapViewController] presentViewController: alertController
																    animated: YES
																  completion:^{
																	 // CPLog(@"has shown alert");
																	
																	  if (setupBlock)
																	  {
																		  if (!weakAlertController)
																			  CPLog(@"NIL ALERT CONTROLLER");
																		  
																		  setupBlock(weakAlertController);
																		  
																	  }

																	  
																  }];
	
	//[self setAlertController: alertController];
}

@end
