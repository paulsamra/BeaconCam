//
//  BCViewController.m
//  BeaconCam
//
//  Created by Ryan Khalili on 5/9/14.
//  Copyright (c) 2014 Swipe Development. All rights reserved.
//

#import "BCInitialVC.h"

@interface BCInitialVC ()

@end

@implementation BCInitialVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)beaconModeSelected
{
    [self performSegueWithIdentifier:@"clientMode" sender:nil];
}

- (IBAction)cameraModeSelected
{
    [self performSegueWithIdentifier:@"serverMode" sender:nil];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end