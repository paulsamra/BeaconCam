//
//  BCViewController.m
//  BeaconCam
//
//  Created by Ryan Khalili on 5/9/14.
//  Copyright (c) 2014 Swipe Development. All rights reserved.
//

#import "BCInitialVC.h"
#import "BCStyleKit.h"
#import "BCUserManager.h"

@interface BCInitialVC()

@property (nonatomic) BOOL shouldShowSignUp;

@end

@implementation BCInitialVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.setupButton setBackgroundImage:[BCStyleKit imageOfSettingsIconWithHighlighted:NO]  forState:UIControlStateNormal];
    [self.setupButton setBackgroundImage:[BCStyleKit imageOfSettingsIconWithHighlighted:YES] forState:UIControlStateHighlighted];
    
    if( ![BCUserManager currentUserEmail] )
    {
        self.shouldShowSignUp = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if( self.shouldShowSignUp )
    {
        [self performSegueWithIdentifier:@"userSetup" sender:nil];
        self.shouldShowSignUp = NO;
    }
}

- (IBAction)beaconModeSelected
{
    [self performSegueWithIdentifier:@"clientMode" sender:nil];
}

- (IBAction)cameraModeSelected
{
    [self performSegueWithIdentifier:@"serverMode" sender:nil];
}

- (IBAction)goToSetup
{
    [self performSegueWithIdentifier:@"userSetup" sender:nil];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end