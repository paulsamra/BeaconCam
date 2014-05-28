//
//  BCCameraModeOptionsVC.m
//  BeaconCam
//
//  Created by Ryan Khalili on 5/9/14.
//  Copyright (c) 2014 Swipe Development. All rights reserved.
//

#import "BCCameraVC.h"
#import "BCBluetoothManager.h"
#import "BCStyleKit.h"
#import "BCUserManager.h"

@interface BCCameraVC() <GPUImageVideoCameraDelegate>

@property (strong, nonatomic) UIView                        *motionView;
@property (strong, nonatomic) NSDate                        *lastTakenDate;
@property (strong, nonatomic) NSTimer                       *warmupTimer;
@property (strong, nonatomic) NSTimer                       *intervalTimer;
@property (strong, nonatomic) NSTimer                       *motionTimer;
@property (strong, nonatomic) NSTimer                       *deadTimer;
@property (strong, nonatomic) CIDetector                    *faceDetector;
@property (strong, nonatomic) NSMutableArray                *availablePhotos;
@property (strong, nonatomic) AVCaptureSession              *captureSession;
@property (strong, nonatomic) GPUImageMotionDetector        *motionDetector;
@property (strong, nonatomic) GPUImageBrightnessFilter      *brightnessFilter;

@property (nonatomic) BOOL initialDetection;
@property (nonatomic) BOOL motionDetected;
@property (nonatomic) int  warmupCount;
@property (nonatomic) int  pictureLimit;

@end


@implementation BCCameraVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupCamera];
    
    UIImage *normalImage = [BCStyleKit imageOfExitButtonWithHighlighted:NO];
    UIImage *highlightedImage = [BCStyleKit imageOfExitButtonWithHighlighted:NO];
    [self.exitButton setBackgroundImage:normalImage forState:UIControlStateNormal];
    [self.exitButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.sensitivitySlider.value = 0.5;
    
    [[BCBluetoothManager sharedManager] startBroadcasting];
    
    self.exitButton.alpha = 0.5;
    
    self.initialDetection = YES;
    
    self.lastTakenDate = nil;
    
    self.availablePhotos = [[NSMutableArray alloc] init];
    
    self.pictureLimit = 6;
    
    NSNumber *pictureInterval = [[NSUserDefaults standardUserDefaults] objectForKey:@"pictureInterval"];
    
    if( pictureInterval )
    {
        self.intervalTimer = [NSTimer scheduledTimerWithTimeInterval:[pictureInterval doubleValue] target:self selector:@selector(takePicture) userInfo:nil repeats:YES];
    }
    else
    {
        self.intervalTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(takePicture) userInfo:nil repeats:YES];
    }
    
    [BCUserManager deviceDidBecomeBeacon:YES];
    
    self.timerLabel.backgroundColor = [BCStyleKit baseButtonColor];
    self.timerLabel.alpha = 0.5;
}

- (void)setupCamera
{
    self.camera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
    
    self.camera.outputImageOrientation = UIInterfaceOrientationLandscapeLeft;
    
    self.motionDetector = [[GPUImageMotionDetector alloc] init];
    [self.motionDetector setLowPassFilterStrength:self.sensitivitySlider.value];
    [self.camera addTarget:self.motionDetector];
    
    self.brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    [self.camera addTarget:self.brightnessFilter];
    
    GPUImageView *filterView = (GPUImageView *)self.view;
    
    self.motionView = [[UIView alloc] initWithFrame:CGRectMake(100.0, 100.0, 100.0, 100.0)];
    self.motionView.layer.borderWidth = 1;
    self.motionView.layer.borderColor = [[UIColor redColor] CGColor];
    [self.view addSubview:self.motionView];
    [self.view addSubview:self.sensitivitySlider];
    self.motionView.hidden = YES;
    
    self.warmupCount = 61;
    self.warmupTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(warmup) userInfo:nil repeats:YES];
    
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
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)warmup
{
    self.warmupCount--;
    
    self.timerLabel.text = [NSString stringWithFormat:@"Warming Up: %d", self.warmupCount];
    
    if( self.warmupCount == 0 )
    {
        self.timerLabel.text = @"";
        [self.warmupTimer invalidate];
    }
}

- (IBAction)exitView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)startDeadTimer
{
    [self.motionTimer invalidate];
    
    self.deadTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(stopDeadTimer) userInfo:nil repeats:NO];
    
    NSLog(@"Sending photos!");
    [self sendAvailablePhotos];
}

- (void)stopDeadTimer
{
    NSLog(@"OUT OF DEAD TIMER");
    self.motionDetected = NO;
    self.pictureLimit   = 6;
    
    [self.deadTimer invalidate];
}

- (void)takePicture
{
    BOOL shouldAlwaysTakePicture = [[BCBluetoothManager sharedManager] shouldAlwaysTakePicture];
    BOOL userInRange = [[BCBluetoothManager sharedManager] userInRange];
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        if( ![self.warmupTimer isValid] )
        {
            if( !userInRange || shouldAlwaysTakePicture )
            {
                self.timerLabel.text = @"Motion Mode: ON";
            }
            else
            {
                self.timerLabel.text = @"Motion Mode: OFF";
            }
        }
    });
    
    BOOL shouldTakePicture = ( shouldAlwaysTakePicture || !userInRange );
    BOOL underLimit = ( self.pictureLimit > 0 );
    
    if( self.motionDetected && shouldTakePicture && ![self.warmupTimer isValid] && ![self.deadTimer isValid] && underLimit )
    {
        if( ![self.motionTimer isValid] )
        {
            self.motionTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(startDeadTimer) userInfo:nil repeats:NO];
        }
        
        NSLog(@"WILL TAKE PICTURE");
        
        self.motionDetected = NO;
        
        [self.brightnessFilter useNextFrameForImageCapture];
        
        [self performSelector:@selector(saveImage) withObject:nil afterDelay:0.2];
    }
    
    self.motionDetected = NO;
}

- (void)saveImage
{
    UIImage *cameraImage = [self.brightnessFilter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
    
    if( cameraImage && !self.initialDetection )
    {
        self.pictureLimit--;
        
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
            
            [self.availablePhotos addObject:filePathToWrite];
            self.lastTakenDate = [NSDate date];
            NSLog(@"PICTURE TAKEN");
        });
    }
    else
    {
        self.initialDetection = NO;
    }
}

- (void)sendAvailablePhotos
{
    BOOL shouldAlwaysTakePicture = [[BCBluetoothManager sharedManager] shouldAlwaysTakePicture];
    BOOL userInRange = [[BCBluetoothManager sharedManager] userInRange];
    
    [BCUserManager sendPhotos:[self.availablePhotos copy] withStatus:( shouldAlwaysTakePicture || userInRange )];
    
    self.availablePhotos = [[NSMutableArray alloc] init];
}

- (IBAction)changeMotionSensitivity:(UISlider *)sender
{
    [self.motionDetector setLowPassFilterStrength:self.sensitivitySlider.value];
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
    [self.intervalTimer invalidate];
    [self.deadTimer invalidate];
    [self.warmupTimer invalidate];
    [self.motionTimer invalidate];
    [BCUserManager deviceDidBecomeBeacon:NO];

    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

@end
