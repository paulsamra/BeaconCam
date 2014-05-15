//
//  BCUserManager.m
//  BeaconCam
//
//  Created by Ryan Khalili on 5/13/14.
//  Copyright (c) 2014 Swipe Development. All rights reserved.
//

#import "BCUserManager.h"
#import "BCBluetoothManager.h"
#import <Parse/Parse.h>

#define kEmailKey @"email"
#define kUserClassKey @"User"
#define kPictureSettingKey @"picture_setting"

@implementation BCUserManager

+ (NSString *)currentUserEmail
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kEmailKey];
}

+ (void)setUserEmail:(NSString *)email
{
    if( ![BCUserManager currentUserEmail] )
    {
        PFQuery *query = [PFQuery queryWithClassName:kUserClassKey];
        [query whereKey:kEmailKey equalTo:email];
        [query findObjectsInBackgroundWithBlock:^( NSArray *objects, NSError *error )
        {
            if( error )
            {
                NSLog( @"%@", error.localizedDescription );
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setObject:email forKey:kEmailKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if( [objects count] == 0 )
                {
                    PFObject *userIDObject = [PFObject objectWithClassName:kUserClassKey];
                    userIDObject[kEmailKey] = email;
                    [userIDObject saveInBackground];
                    
                    [[PFInstallation currentInstallation] setObject:userIDObject forKey:@"user"];
                    [[PFInstallation currentInstallation] saveInBackground];
                }
                else
                {
                    [[PFInstallation currentInstallation] setObject:[objects lastObject] forKey:@"user"];
                    [[PFInstallation currentInstallation] saveInBackground];
                    
                    NSLog(@"Email already exists.");
                }
            }
        }];
    }
    
    else
    {
        PFQuery *query = [PFQuery queryWithClassName:kUserClassKey];
        [query whereKey:kEmailKey equalTo:[BCUserManager currentUserEmail]];
        [query findObjectsInBackgroundWithBlock:^( NSArray *objects, NSError *error )
        {
            if( error )
            {
                NSLog( @"%@", error.localizedDescription );
            }
            else
            {
                if( [objects count] == 0 )
                {
                    PFObject *userIDObject = [PFObject objectWithClassName:kUserClassKey];
                    userIDObject[kEmailKey] = email;
                    [userIDObject saveInBackground];
                    
                    [[PFInstallation currentInstallation] setObject:userIDObject forKey:@"user"];
                    [[PFInstallation currentInstallation] saveInBackground];
                }
                else
                {
                    PFObject *userObject = [objects lastObject];
                    userObject[kEmailKey] = email;
                    [userObject saveInBackground];
                }
            }
        }];
    }
}

+ (void)notifyBeaconWithStatus:(BOOL)inside
{
    PFQuery *userQuery = [PFQuery queryWithClassName:kUserClassKey];
    [userQuery whereKey:kEmailKey equalTo:[BCUserManager currentUserEmail]];
    
    PFQuery *installationQuery = [PFInstallation query];
    [installationQuery whereKey:@"user" matchesQuery:userQuery];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:installationQuery];
    
    NSString *message = inside ? kBeaconFound : kExitedBeconRegion;
    
    [push setMessage:message];
    [push sendPushInBackground];
}

+ (BOOL)shouldAlwaysTakePicture
{
    BOOL alwaysTakePicture = NO;
    
    NSNumber *setting = [[NSUserDefaults standardUserDefaults] objectForKey:kPictureSettingKey];
    
    if( setting )
    {
        alwaysTakePicture = [setting boolValue];
    }
    
    return alwaysTakePicture;
}

+ (void)setShouldAlwaysTakePictureSetting:(BOOL)setting
{
    NSNumber *value = [NSNumber numberWithBool:setting];
    
    [[BCBluetoothManager sharedManager] setShouldAlwaysTakePicture:setting];
    
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:kPictureSettingKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)handlePush:(NSDictionary *)info
{
    NSString *message = info[@"aps"][@"alert"];
    
    if( [message isEqualToString:kBeaconFound] )
    {
        [[BCBluetoothManager sharedManager] setUserInRange:YES];
    }
    
    if( [message isEqualToString:kExitedBeconRegion] )
    {
        [[BCBluetoothManager sharedManager] setUserInRange:NO];
    }
}

@end