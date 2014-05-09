//
//  BCBeaconManager.h
//  BeaconCam
//
//  Created by Ryan Khalili on 5/9/14.
//  Copyright (c) 2014 Swipe Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCManager : NSObject

+ (BCManager *)sharedManager;

- (void)startBroadcasting;
- (void)stopBroadcasting;

- (void)startListeningForBeacons;
- (void)stopListeningForBeacons;

- (BOOL)beaconHasBeenFound;

@end