//
//  BCCameraModeOptionsVC.h
//  BeaconCam
//
//  Created by Ryan Khalili on 5/9/14.
//  Copyright (c) 2014 Swipe Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GPUImage.h"

@interface BCCameraVC : UIViewController

@property (strong, nonatomic) GPUImageStillCamera *camera;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;
@property (weak, nonatomic) IBOutlet UISlider *sensitivitySlider;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

@end