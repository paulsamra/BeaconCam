//
//  BCSetupVC.m
//  BeaconCam
//
//  Created by Ryan Khalili on 5/13/14.
//  Copyright (c) 2014 Swipe Development. All rights reserved.
//

#import "BCSetupVC.h"
#import "BCUserManager.h"

@interface BCSetupVC() <UITextFieldDelegate>

@end

@implementation BCSetupVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *email = [BCUserManager currentUserEmail];
    
    if( email )
    {
        self.emailField.text = email;
    }
    
    self.emailField.delegate = self;
    
    self.alwaysTakePictureSwitch.on = [BCUserManager shouldAlwaysTakePicture];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)submitEmail
{
    [BCUserManager setUserEmail:self.emailField.text];
    
    [self dismissViewControllerAnimated:YES completion:nil];
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

@end
