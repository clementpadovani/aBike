//
//  VEExtensionDelegate.m
//  aBike—Lyon
//
//  Created by Clément Padovani on 3/27/16.
//  Copyright © 2016 Clement Padovani. All rights reserved.
//

#import "VEExtensionDelegate.h"
#import "VEWatchBikeStation.h"

@implementation VEExtensionDelegate

- (void) sessionReachabilityDidChange: (WCSession *) session
{
    NSLog(@"reachability: %@", session);
}

- (void) session: (WCSession *) session didReceiveApplicationContext: (NSDictionary <NSString *, id> *) applicationContext
{
    NSArray <NSData *> *stationsData = applicationContext[@"stations"];

    NSMutableArray <VEWatchBikeStation *> *stations = [NSMutableArray arrayWithCapacity: [stationsData count]];

    for (NSData *aStationsData in stationsData)
    {
        VEWatchBikeStation *aStation = [NSKeyedUnarchiver unarchiveObjectWithData: aStationsData];

        if ([aStation isKindOfClass: [VEWatchBikeStation class]])
        {
            [stations addObject: aStation];
        }
        else
        {
            NSLog(@"not a station: %@", aStation);
        }
    }

//    NSLog(@"received data: %@", stations);



    NSLog(@"did receive data");

//    dispatch_async(dispatch_get_main_queue(), ^{

    WKInterfaceController *rootInterfaceController = [[WKExtension sharedExtension] rootInterfaceController];

    NSMutableArray *controllerNames = [NSMutableArray arrayWithCapacity: [stations count]];

    for (NSUInteger i = 0; i < [stations count]; i++)
    {
        [controllerNames addObject: @"mainScene"];
    }


    [rootInterfaceController presentControllerWithNames: controllerNames
                                               contexts: stations];
//    });
}

- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(NSError *)error
{
    NSLog(@"activate: %ld", (long) activationState);

    if (error)
        NSLog(@"error: %@", error);
}

- (void) applicationDidFinishLaunching
{
    if ([WCSession isSupported])
    {
        WCSession *session = [WCSession defaultSession];

        [session setDelegate: self];

        [session activateSession];

        NSLog(@"activated");

        if ([session respondsToSelector: @selector(activationState)])
        {
            if ([session activationState] == WCSessionActivationStateNotActivated)
            {
                if ([session iOSDeviceNeedsUnlockAfterRebootForReachability])
                {
                    NSString *messageString = @"Unlock your device to use ";

                    messageString = [messageString stringByAppendingString: [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleDisplayName"]];

                    WKAlertAction *closeAction = [WKAlertAction actionWithTitle: @"OK"
                                                                          style: WKAlertActionStyleDefault
                                                                        handler: ^{
                                                                            NSLog(@"close");
                                                                        }];

                    [[[WKExtension sharedExtension] rootInterfaceController] presentAlertControllerWithTitle: @"Unlock device"
                                                                                                     message: messageString
                                                                                              preferredStyle: WKAlertControllerStyleAlert
                                                                                                     actions: @[closeAction]];
                }
            }
        }
    }
}

- (void) applicationDidBecomeActive
{
}

@end
