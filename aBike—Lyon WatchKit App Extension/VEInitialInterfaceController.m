//
//  VEInitialInterfaceController.m
//  aBike—Lyon
//
//  Created by Clément Padovani on 4/30/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

#import "VEInitialInterfaceController.h"

@interface VEInitialInterfaceController ()
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *openMainAppLabel;

@end

@implementation VEInitialInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void) willActivate
{
    [super willActivate];

    [[self openMainAppLabel] setText: @"Please open the app on your iPhone to view the nearby stations."];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



