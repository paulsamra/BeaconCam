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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(foundBeaconNotification:) name:kBeaconFound object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitedBeaconRegion) name:kExitedBeconRegion object:nil];
}

- (void)foundBeaconNotification:(NSNotification *)notification
{
    NSLog(@"%@", notification.object);
    self.beaconLabel.text = notification.object;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[BCManager sharedManager] stopListeningForBeacons];
}

- (void)exitedBeaconRegion
{
    self.beaconLabel.text = @"No Beacon Found";
}

@end
