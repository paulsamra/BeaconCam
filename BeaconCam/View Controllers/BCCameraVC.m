//
//  BCCameraModeOptionsVC.m
//  BeaconCam
//
//  Created by Ryan Khalili on 5/9/14.
//  Copyright (c) 2014 Swipe Development. All rights reserved.
//

#import "BCCameraVC.h"
#import "BCBluetoothManager.h"

@interface BCCameraVC()

@property (strong, nonatomic) UIView                        *motionView;
@property (strong, nonatomic) NSDate                        *lastTakenDate;
@property (strong, nonatomic) NSTimer                       *cameraTimer;
@property (strong, nonatomic) CIDetector                    *faceDetector;
@property (strong, nonatomic) AVCaptureSession              *captureSession;
@property (strong, nonatomic) GPUImageMotionDetector        *motionDetector;
@property (strong, nonatomic) GPUImageBrightnessFilter      *brightnessFilter;

@property (nonatomic) int  initializeCounter;
@property (nonatomic) BOOL motionDetected;

@end


@implementation BCCameraVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupCamera];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [[BCBluetoothManager sharedManager] startBroadcasting];
    
    self.exitButton.alpha = 0.5;
    
    self.initializeCounter = 0;
    
    self.lastTakenDate = [NSDate date];
    
    self.cameraTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(takePicture) userInfo:nil repeats:YES];
}

- (void)setupCamera
{
    self.camera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
    
    self.camera.outputImageOrientation = UIInterfaceOrientationLandscapeLeft;
    
    self.motionDetector = [[GPUImageMotionDetector alloc] init];
    [(GPUImageMotionDetector *)self.motionDetector setLowPassFilterStrength:0.5];
    [self.camera addTarget:self.motionDetector];
    
    self.brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    [self.camera addTarget:self.brightnessFilter];
    
    GPUImageView *filterView = (GPUImageView *)self.view;
    
    self.motionView = [[UIView alloc] initWithFrame:CGRectMake(100.0, 100.0, 100.0, 100.0)];
    self.motionView.layer.borderWidth = 1;
    self.motionView.layer.borderColor = [[UIColor redColor] CGColor];
    [self.view addSubview:self.motionView];
    self.motionView.hidden = YES;
    
    __unsafe_unretained BCCameraVC *weakSelf = self;
    [(GPUImageMotionDetector *)self.motionDetector setMotionDetectionBlock:
    ^(CGPoint motionCentroid, CGFloat motionIntensity, CMTime frameTime)
    {
        if( motionIntensity > 0.05 )
        {
            CGFloat motionBoxWidth = 1500.0 * motionIntensity;
            CGSize viewBounds = weakSelf.view.bounds.size;
            weakSelf.motionDetected = YES;
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
    
    [self.camera addTarget:filterView];
    
    [self.camera startCameraCapture];
}

- (IBAction)exitView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)takePicture
{
    BOOL shouldAlwaysTakePicture = [[BCBluetoothManager sharedManager] shouldAlwaysTakePicture];
    BOOL userInRange = [[BCBluetoothManager sharedManager] userInRange];
    
    if( self.motionDetected && ( shouldAlwaysTakePicture || userInRange ) )
    {
        self.motionDetected = NO;
        
        [self.brightnessFilter useNextFrameForImageCapture];
        
        [self performSelector:@selector(saveImage) withObject:nil afterDelay:0.1];
    }
}

- (void)saveImage
{
    UIImage *cameraImage = [self.brightnessFilter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
    
    if( cameraImage )
    {
        dispatch_queue_t backgroundQueue = dispatch_queue_create("imageSaveThread", 0);
        
        dispatch_async(backgroundQueue, ^
        {
            NSData   *pictureData = UIImageJPEGRepresentation(cameraImage, 0.8);
            
            NSArray  *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [directories objectAtIndex:0];
            
            NSError  *error = nil;
            NSString *fileName = [NSString stringWithFormat:@"image-%@", [NSDate date]];
            NSString *filePathToWrite = [documentsDirectory stringByAppendingPathComponent:fileName];
            
            [pictureData writeToFile:filePathToWrite options:NSAtomicWrite error:&error];
            
            if( error )
            {
                NSLog(@"%@", error.localizedDescription );
                return;
            }
            
            self.lastTakenDate = [NSDate date];
            NSLog(@"PICTURE TAKEN");
        });
    }
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
    [[BCBluetoothManager sharedManager] stopBroadcasting];
    [self.camera stopCameraCapture];
    [self.cameraTimer invalidate];
}

@end
