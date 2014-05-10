//
//  BCCameraModeOptionsVC.m
//  BeaconCam
//
//  Created by Ryan Khalili on 5/9/14.
//  Copyright (c) 2014 Swipe Development. All rights reserved.
//

#import "BCCameraVC.h"
#import "BCManager.h"

@interface BCCameraVC ()

@property (strong, nonatomic) AVCaptureSession *captureSession;

@end

@implementation BCCameraVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:[self backCamera] error:nil];
    if( [self.captureSession canAddInput:videoInput] )
    {
        [self.captureSession addInput:videoInput];
    }
    
    AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = @{ AVVideoCodecKey : AVVideoCodecJPEG };
    [imageOutput setOutputSettings:outputSettings];
    
    if( [self.captureSession canAddOutput:imageOutput] )
    {
        [self.captureSession addOutput:imageOutput];
    }
    
    self.videoLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    
    [self.view.layer setMasksToBounds:YES];
    
    CGSize landscapeSize;
    landscapeSize.width = self.view.bounds.size.height;
    landscapeSize.height = self.view.bounds.size.width;
    
    CGRect landscapeRect;
    landscapeRect.size = landscapeSize;
    landscapeRect.origin = self.view.bounds.origin;
    
    self.videoLayer.frame = landscapeRect;
    
    if(self.videoLayer.connection.supportsVideoOrientation)
    {
        self.videoLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    }
    
    [self.videoLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.view.layer addSublayer:self.videoLayer];
    
    [self.captureSession startRunning];
    
    [[BCManager sharedManager] startBroadcasting];
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in devices)
    {
        if ( [device position] == position )
        {
            return device;
        }
    }
    
    return nil;
}

- (AVCaptureDevice *)backCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[BCManager sharedManager] stopBroadcasting];
}

@end
