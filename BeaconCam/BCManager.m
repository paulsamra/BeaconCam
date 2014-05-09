//
//  BCBeaconManager.m
//  BeaconCam
//
//  Created by Ryan Khalili on 5/9/14.
//  Copyright (c) 2014 Swipe Development. All rights reserved.
//

#import "BCManager.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

static NSString *kBeaconID           = @"com.swipedevelopment.beaconCam";
static NSString *kBeaconUUID         = @"4B5B9305-BA7F-4E69-B985-FB505253D81F";
static NSString *kBeaconListenerUUID = @"B591671C-6D42-4EC5-A842-A80416ADD65D";


@interface BCManager() <CBPeripheralManagerDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager   *locationManager;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) CLBeaconRegion      *beaconRegion;

@property (nonatomic) BOOL beaconFound;

@end

@implementation BCManager

+ (BCManager *)sharedManager
{
    static BCManager *manager = nil;
    
    static dispatch_once_t singleton;
    
    dispatch_once(&singleton, ^{
        manager = [[BCManager alloc] init];
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
    }
    
    return self;
}

- (void)startBroadcasting
{
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:kBeaconUUID];
    
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:kBeaconID];
    
    NSDictionary *peripheralData = [beaconRegion peripheralDataWithMeasuredPower:nil];
    
    [self.peripheralManager startAdvertising:peripheralData];
}

- (void)stopBroadcasting
{
    [self.peripheralManager stopAdvertising];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    
}

- (void)startListeningForBeacons
{
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:kBeaconListenerUUID];
    
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:kBeaconID];
    
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    
    NSLog(@"started");
}

- (void)stopListeningForBeacons
{
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSLog(@"did range");
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    NSLog(@"ranging failed");
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
}

- (BOOL)beaconHasBeenFound
{
    return YES;
}

@end
