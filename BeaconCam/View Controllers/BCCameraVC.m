//
//  BCCameraModeOptionsVC.m
//  BeaconCam
//
//  Created by Ryan Khalili on 5/9/14.
//  Copyright (c) 2014 Swipe Development. All rights reserved.
//

#import "BCCameraVC.h"
#import "BCManager.h"

@interface BCCameraVC()

@property (strong, nonatomic) UIView                        *motionView;
@property (strong, nonatomic) CIDetector                    *faceDetector;
@property (strong, nonatomic) AVCaptureSession              *captureSession;
@property (strong, nonatomic) GPUImageOutput<GPUImageInput> *filter;

@end


@implementation BCCameraVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupCamera];
        
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [[BCManager sharedManager] startBroadcasting];
}

- (void)setupCamera
{
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
    
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationLandscapeLeft;
    
    self.filter = [[GPUImageMotionDetector alloc] init];
    [(GPUImageMotionDetector *)self.filter setLowPassFilterStrength:0.5];
    [self.videoCamera addTarget:self.filter];
    
    GPUImageView *filterView = (GPUImageView *)self.view;
    
    self.motionView = [[UIView alloc] initWithFrame:CGRectMake(100.0, 100.0, 100.0, 100.0)];
    self.motionView.layer.borderWidth = 1;
    self.motionView.layer.borderColor = [[UIColor redColor] CGColor];
    [self.view addSubview:self.motionView];
    self.motionView.hidden = YES;
    
    __unsafe_unretained BCCameraVC *weakSelf = self;
    [(GPUImageMotionDetector *)self.filter setMotionDetectionBlock:
    ^(CGPoint motionCentroid, CGFloat motionIntensity, CMTime frameTime)
    {
        if( motionIntensity > 0.01 )
        {
            CGFloat motionBoxWidth = 1500.0 * motionIntensity;
            CGSize viewBounds = weakSelf.view.bounds.size;
            dispatch_async(dispatch_get_main_queue(), ^
            {
                weakSelf->_motionView.frame = CGRectMake(round(viewBounds.width * motionCentroid.x - motionBoxWidth / 2.0), round(viewBounds.height * motionCentroid.y - motionBoxWidth / 2.0), motionBoxWidth, motionBoxWidth);
                weakSelf->_motionView.hidden = NO;
            });
            
        }
        
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                weakSelf->_motionView.hidden = YES;
            });
        }
    }];
    
    [self.videoCamera addTarget:filterView];
    
    [self.videoCamera startCameraCapture];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeLeft;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[BCManager sharedManager] stopBroadcasting];
}

@end
