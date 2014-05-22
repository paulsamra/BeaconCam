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

#define kEmailKey           @"email"
#define kUserClass          @"User"
#define kPictureSettingKey  @"picture_setting"
#define kUserPhotoClass     @"UserPhoto"
#define kPhotoFileName      @"image.jpg"
#define kPhotoKey           @"photo"
#define kInsideRegionKey    @"insideRegion"

@implementation BCUserManager

+ (NSString *)currentUserEmail
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kEmailKey];
}

+ (void)setUserEmail:(NSString *)email
{
    if( ![BCUserManager currentUserEmail] )
    {
        PFQuery *query = [PFQuery queryWithClassName:kUserClass];
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
                    PFObject *userIDObject = [PFObject objectWithClassName:kUserClass];
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
        PFQuery *query = [PFQuery queryWithClassName:kUserClass];
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
                    PFObject *userIDObject = [PFObject objectWithClassName:kUserClass];
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

+ (void)determineUserRegionStatus
{
    PFQuery *userQuery = [PFQuery queryWithClassName:kUserClass];
    [userQuery whereKey:kEmailKey equalTo:[BCUserManager currentUserEmail]];
    [userQuery findObjectsInBackgroundWithBlock:^( NSArray *objects, NSError *error )
    {
        if( error )
        {
            NSLog( @"%@", error.localizedDescription );
        }
        else
        {
            PFObject *userObject = [objects lastObject];
            BOOL inRange = [userObject[kInsideRegionKey] boolValue];
            [[BCBluetoothManager sharedManager] setUserInRange:inRange];
        }
    }];
}

+ (void)notifyBeaconWithStatus:(BOOL)inside
{
    PFQuery *userQuery = [PFQuery queryWithClassName:kUserClass];
    [userQuery whereKey:kEmailKey equalTo:[BCUserManager currentUserEmail]];
    
    PFQuery *installationQuery = [PFInstallation query];
    [installationQuery whereKey:@"user" matchesQuery:userQuery];
    [installationQuery whereKey:@"installationId" notEqualTo:[[PFInstallation currentInstallation] installationId]];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:installationQuery];
    
    NSString *message = inside ? kBeaconFound : kExitedBeconRegion;
    
    [push setMessage:message];
    [push sendPushInBackground];
    
    [userQuery findObjectsInBackgroundWithBlock:^( NSArray *objects, NSError *error )
    {
        if( error )
        {
            NSLog( @"%@", error.localizedDescription );
        }
        else
        {
            PFObject *userObject = [objects objectAtIndex:0];
            userObject[kInsideRegionKey] = [NSNumber numberWithBool:inside];
            [userObject saveInBackground];
        }
    }];
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

+ (void)uploadPhoto:(NSData *)imageData withStatus:(BOOL)friendly
{
    PFFile   *imageFile = [PFFile fileWithName:kPhotoFileName data:imageData];
    PFObject *newUserPhoto = [PFObject objectWithClassName:kUserPhotoClass];
    [newUserPhoto setObject:imageFile forKey:kPhotoKey];
    
    PFQuery *userQuery = [PFQuery queryWithClassName:kUserClass];
    [userQuery whereKey:kEmailKey equalTo:[BCUserManager currentUserEmail]];
}

@end