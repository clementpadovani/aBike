//
//  VEAlertControllerManager.h
//  aBikeLibrary
//
//  Created by Clément Padovani on 9/10/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "VEAlertManager.h"

@interface VEAlertControllerManager : NSObject

+ (VEAlertControllerManager *) sharedManager;

- (void) showAlertOfType: (VEAlertType) alertType withConfigurationBlock: (VEAlertManagerConfigurationBlock) configurationBlock withHasSetupBlock: (VEAlertManagerHasSetupBlock) setupBlock withCompletionBlock: (VEAlertManagerCompletionBlock) completionBlock;


@end
