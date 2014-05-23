//
//  BCBeaconManager.m
//  BeaconCam
//
//  Created by Ryan Khalili on 5/9/14.
//  Copyright (c) 2014 Swipe Development. All rights reserved.
//

#import "BCBluetoothManager.h"
#import "BCUserManager.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

static NSString *kBeaconID   = @"com.swipedevelopment.beaconCam";
static NSString *kBeaconUUID = @"4B5B9305-BA7F-4E69-B985-FB505253D81F";

@interface BCBluetoothManager() <CBPeripheralManagerDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager   *locationManager;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) CLBeaconRegion      *beaconRegion;

@property (nonatomic) BOOL initialRegionCheck;
@property (nonatomic) BOOL inBeaconRegion;
@property (nonatomic) BOOL listeningForBeacons;

@end

@implementation BCBluetoothManager

+ (BCBluetoothManager *)sharedManager
{
    static BCBluetoothManager *manager = nil;
    
    static dispatch_once_t singleton;
    
    dispatch_once(&singleton, ^{
        manager = [[BCBluetoothManager alloc] init];
    });
    
    return manager;
}

- (id)init
{
    self = [super init];
    
    if( self )
    {
        _locationManager   = [[CLLocationManager alloc] init];
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
        
        _locationManager.delegate = self;
        
        _shouldAlwaysTakePicture = [BCUserManager shouldAlwaysTakePicture];
        _userInRange = NO;
        _initialRegionCheck = YES;
        
        NSSet *rangedRegions = _locationManager.monitoredRegions;
        _listeningForBeacons = [rangedRegions count] ? YES : NO;
        
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:kBeaconUUID];
        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:kBeaconID];
        _beaconRegion.notifyEntryStateOnDisplay = YES;
    }
    
    return self;
}

#pragma mark iBeacon Code

// Start broadcasting as iBeacon.
- (void)startBroadcasting
{
    NSDictionary *peripheralData = [self.beaconRegion peripheralDataWithMeasuredPower:nil];
    
    [self.peripheralManager startAdvertising:peripheralData];
}

// Stop broadcasting as iBeacon.
- (void)stopBroadcasting
{
    [self.peripheralManager stopAdvertising];
}

// Required CBPeripheralManager delegate method.
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if( !error )
    {
        NSLog(@"Started advertising.");
    }
    else
    {
        NSLog(@"Error advertising.");
    }
}

// Peripheral manager state update.
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    switch( peripheral.state )
    {
        case CBPeripheralManagerStateUnknown:      NSLog(@"Unknown");      break;
        case CBPeripheralManagerStateResetting:    NSLog(@"Resetting");    break;
        case CBPeripheralManagerStateUnsupported:  NSLog(@"Unsupported");  break;
        case CBPeripheralManagerStateUnauthorized: NSLog(@"Unauthorized"); break;
        case CBPeripheralManagerStatePoweredOff:   NSLog(@"Powered Off");  break;
        case CBPeripheralManagerStatePoweredOn:    NSLog(@"Powered On");   break;
    }
}

#pragma mark Beacon listening code

// Start ranging for iBeacons.
- (void)startListeningForBeacons
{
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    [self.locationManager requestStateForRegion:self.beaconRegion];
    self.listeningForBeacons = YES;
}

// Stop ranging for iBeacons.
- (void)stopListeningForBeacons
{
    [self.locationManager stopMonitoringForRegion:self.beaconRegion];
    self.listeningForBeacons = NO;
    self.inBeaconRegion = NO;
    
    [BCUserManager notifyBeaconWithStatus:NO];
}

- (BOOL)isListeningForBeacons
{
    return self.listeningForBeacons;
}

// Entered iBeacon region.
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    self.inBeaconRegion = YES;
    //[BCUserManager notifyBeaconWithStatus:YES];
    NSLog(@"Entered iBeacon region.");
}

// Exited iBeacon region.
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    self.inBeaconRegion = NO;
    //[BCUserManager notifyBeaconWithStatus:NO];
    NSLog(@"Exited iBeacon region.");
}

// Determined region state.
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    switch( state )
    {
        case CLRegionStateInside:
        {
            NSLog(@"Inside Region");
            self.inBeaconRegion = YES;
            [BCUserManager notifyBeaconWithStatus:YES];
        }
        break;
        
        case CLRegionStateOutside:
        {
            NSLog(@"Outside Region");
            self.inBeaconRegion = NO;
            [BCUserManager notifyBeaconWithStatus:NO];
        }
        break;
        
        case CLRegionStateUnknown:
        {
            NSLog(@"Unknown State");
            self.inBeaconRegion = NO;
        }
        break;
    }
}

//// iBeacon has been ranged.
//- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
//{
//    [self.locationManager requestStateForRegion:self.beaconRegion];
//}
//
//// iBeacon ranging failed.
//- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
//{
//    NSLog(@"iBeacon ranging failed with error: %@", error.localizedDescription);
//}

@end
