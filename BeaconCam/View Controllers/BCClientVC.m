//
//  BCClientVC.m
//  BeaconCam
//
//  Created by Ryan Khalili on 5/9/14.
//  Copyright (c) 2014 Swipe Development. All rights reserved.
//

#import "BCClientVC.h"
#import "BCManager.h"

@interface BCClientVC ()

@end

@implementation BCClientVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.beaconLabel.text = @"No Beacon Found";
    
    [[BCManager sharedManager] startListeningForBeacons];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(foundBeacon:) name:kBeaconFound object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitedRegion) name:kExitedBeconRegion object:nil];
}

- (void)foundBeacon:(NSNotification *)notification
{
    NSLog(@"%@", notification.object);
    self.beaconLabel.text = notification.object;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[BCManager sharedManager] stopListeningForBeacons];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)exitedRegion
{
    self.beaconLabel.text = @"No Beacon Found";
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
