//
//  BCPhotoBrowser.m
//  BeaconCam
//
//  Created by Ryan Khalili on 5/27/14.
//  Copyright (c) 2014 Swipe Development. All rights reserved.
//

#import "BCPhotoBrowser.h"

@interface BCPhotoBrowser ()

@property (strong, nonatomic) UIActionSheet *actionSheet;

@end

@implementation BCPhotoBrowser

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithTitle:@"Take Action" style:UIBarButtonItemStylePlain target:self action:@selector(showActionSheet)];
    self.navigationItem.rightBarButtonItem = actionButton;
}

- (void)showActionSheet
{
    [self.actionSheet showInView:self.view];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    if( ( toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft  ) ||
        ( toInterfaceOrientation == UIInterfaceOrientationLandscapeRight ) )
    {
        self.alwaysShowControls = NO;
    }
    else
    {
        self.alwaysShowControls = YES;
    }
}

- (UIActionSheet *)actionSheet
{
    if( !_actionSheet )
    {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Action To Take" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Notify Police", @"Delay for 1 Hour", nil];
    }
    
    return _actionSheet;
}

@end