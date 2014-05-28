//
//  BCSetupVC.m
//  BeaconCam
//
//  Created by Ryan Khalili on 5/13/14.
//  Copyright (c) 2014 Swipe Development. All rights reserved.
//

#import "BCSetupVC.h"
#import "BCUserManager.h"
#import "BCStyleKit.h"

@interface BCSetupVC() <UITextFieldDelegate>

@property (strong, nonatomic) UIAlertView *emailAlert;
@property (strong, nonatomic) UIAlertView *pictureIntervalAlert;

@end

@implementation BCSetupVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *normalImage = [BCStyleKit imageOfGenericButtonWithText:@"Submit" highlighted:NO];
    UIImage *highlightedImage = [BCStyleKit imageOfGenericButtonWithText:@"Submit" highlighted:YES];
    [self.submitButton setBackgroundImage:normalImage forState:UIControlStateNormal];
    [self.submitButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    
    NSString *email = [BCUserManager currentUserEmail];
    
    if( email )
    {
        self.emailField.text = email;
    }
    
    double pictureInterval = 0.5;
    
    if( [[NSUserDefaults standardUserDefaults] objectForKey:@"pictureInterval"] )
    {
        pictureInterval = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pictureInterval"] doubleValue];
    }
    
    self.pictureIntervalField.text = [NSString stringWithFormat:@"%.1f", pictureInterval];
    
    self.emailField.delegate = self;
    
    self.alwaysTakePictureSwitch.on = [BCUserManager shouldAlwaysTakePicture];
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    self.versionLabel.text = [NSString stringWithFormat:@"Alpha %@", appVersion];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)submitEmail
{
    if( self.emailField.text.length == 0 )
    {
        [self.emailAlert show];
    }
    
    if( [self.pictureIntervalField.text doubleValue] < 0.3 )
    {
        [self.pictureIntervalAlert show];
    }
    
    else
    {
        [BCUserManager setUserEmail:[self.emailField.text lowercaseString]];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.pictureIntervalField.text forKey:@"pictureInterval"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (IBAction)settingChanged
{
    [BCUserManager setShouldAlwaysTakePictureSetting:self.alwaysTakePictureSwitch.on];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIAlertView *)emailAlert
{
    if( !_emailAlert )
    {
        _emailAlert = [[UIAlertView alloc] initWithTitle:@"You must enter an email address!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    }
    
    return _emailAlert;
}

- (UIAlertView *)pictureIntervalAlert
{
    if( !_pictureIntervalAlert )
    {
        _pictureIntervalAlert = [[UIAlertView alloc] initWithTitle:@"Interval must be greater than 0.3 seconds!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    }
    
    return _pictureIntervalAlert;
}

@end
