//
//  BCViewController.h
//  BeaconCam
//
//  Created by Ryan Khalili on 5/9/14.
//  Copyright (c) 2014 Swipe Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCInitialVC : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *cameraModeButton;
@property (weak, nonatomic) IBOutlet UIButton *enableBeaconSearchButton;
@property (weak, nonatomic) IBOutlet UIButton *setupButton;
@property (weak, nonatomic) IBOutlet UIButton *viewPhotosButton;
@property (weak, nonatomic) IBOutlet UILabel *beaconStatusLabel;

@end