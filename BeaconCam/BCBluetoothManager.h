//
//  BCBeaconManager.h
//  BeaconCam
//
//  Created by Ryan Khalili on 5/9/14.
//  Copyright (c) 2014 Swipe Development. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kBeaconFound       @"beacon_found"
#define kExitedBeconRegion @"exited_beacon_region"

@interface BCBluetoothManager : NSObject

@property (nonatomic) BOOL shouldAlwaysTakePicture;
@property (nonatomic) BOOL userInRange;

+ (BCBluetoothManager *)sharedManager;

- (void)startBroadcasting;
- (void)stopBroadcasting;

- (void)startListeningForBeacons;
- (void)stopListeningForBeacons;
- (BOOL)isListeningForBeacons;

@end