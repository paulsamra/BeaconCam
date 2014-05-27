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
#import "BCBluetoothManager.h"

@interface BCInitialVC()

@property (strong, nonatomic) NSTimer *checkRangeTimer;

@property (nonatomic) BOOL shouldShowSignUp;

@end

@implementation BCInitialVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if( ![BCUserManager currentUserEmail] )
    {
        self.shouldShowSignUp = YES;
    }
    
    [self setupButtons];
    
    self.rangeStatusLabel.text = [[BCBluetoothManager sharedManager] inBeaconRegion] ? @"In Range" : @"Not In Range";
    
    self.checkRangeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateRangeLabel) userInfo:nil repeats:YES];
}

- (void)updateRangeLabel
{
    self.rangeStatusLabel.text = [[BCBluetoothManager sharedManager] inBeaconRegion] ? @"In Range" : @"Not In Range";
}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateBeaconStatusUI];
}

- (void)updateBeaconStatusUI
{
    if( [[BCBluetoothManager sharedManager] isListeningForBeacons] )
    {
        self.beaconStatusLabel.text = @"Beacons are being monitored.";
        
        UIImage *normalImage = [BCStyleKit imageOfGenericButtonWithText:@"Disable Beacon Search" highlighted:NO];
        UIImage *highlightedImage = [BCStyleKit imageOfGenericButtonWithText:@"Disable Beacon Search" highlighted:YES];
        [self.enableBeaconSearchButton setBackgroundImage:normalImage      forState:UIControlStateNormal];
        [self.enableBeaconSearchButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    }
    
    else
    {
        self.beaconStatusLabel.text = @"Beacons are not being monitored.";
        
        UIImage *normalImage = [BCStyleKit imageOfGenericButtonWithText:@"Enable Beacon Search" highlighted:NO];
        UIImage *highlightedImage = [BCStyleKit imageOfGenericButtonWithText:@"Enable Beacon Search" highlighted:YES];
        [self.enableBeaconSearchButton setBackgroundImage:normalImage      forState:UIControlStateNormal];
        [self.enableBeaconSearchButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    }
}

- (void)setupButtons
{
    UIImage *normalImage = [BCStyleKit imageOfSettingsIconWithHighlighted:NO];
    UIImage *highlightedImage = [BCStyleKit imageOfSettingsIconWithHighlighted:YES];
    [self.setupButton setBackgroundImage:normalImage      forState:UIControlStateNormal];
    [self.setupButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    
    normalImage = [BCStyleKit imageOfGenericButtonWithText:@"View Photos" highlighted:NO];
    highlightedImage = [BCStyleKit imageOfGenericButtonWithText:@"View Photos" highlighted:YES];
    [self.viewPhotosButton setBackgroundImage:normalImage      forState:UIControlStateNormal];
    [self.viewPhotosButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    
    normalImage = [BCStyleKit imageOfGenericButtonWithText:@"Camera Mode" highlighted:NO];
    highlightedImage = [BCStyleKit imageOfGenericButtonWithText:@"Camera Mode" highlighted:YES];
    [self.cameraModeButton setBackgroundImage:normalImage      forState:UIControlStateNormal];
    [self.cameraModeButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
}

- (void)viewDidAppear:(BOOL)animated
{
    if( self.shouldShowSignUp )
    {
        [self performSegueWithIdentifier:@"userSetup" sender:nil];
        self.shouldShowSignUp = NO;
    }
}

- (IBAction)enableBeaconSearch
{
    if( ![[BCBluetoothManager sharedManager] isListeningForBeacons] )
    {
        [[BCBluetoothManager sharedManager] startListeningForBeacons];
        NSLog(@"start listening");
    }
    
    else
    {
        [[BCBluetoothManager sharedManager] stopListeningForBeacons];
        NSLog(@"stop listening");
    }
    
    [self updateBeaconStatusUI];
}

- (IBAction)cameraModeSelected
{
    [self performSegueWithIdentifier:@"serverMode" sender:nil];
}

- (IBAction)goToSetup
{
    [self performSegueWithIdentifier:@"userSetup" sender:nil];
}

- (IBAction)goToPhotos
{
    [self performSegueWithIdentifier:@"viewPhotos" sender:nil];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end