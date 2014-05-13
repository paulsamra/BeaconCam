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

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *videoLayer;
@property (strong, nonatomic) GPUImageVideoCamera *videoCamera;

@end