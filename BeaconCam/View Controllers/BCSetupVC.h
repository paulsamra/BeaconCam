//
//  BCSetupVC.h
//  BeaconCam
//
//  Created by Ryan Khalili on 5/13/14.
//  Copyright (c) 2014 Swipe Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCSetupVC : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UISwitch *alwaysTakePictureSwitch;

@end
