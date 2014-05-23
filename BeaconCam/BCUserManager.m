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
#define kPhotoSetClass      @"UserPhotoSet"
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
    NSString *currentUserEmail = [BCUserManager currentUserEmail];
    
    if( currentUserEmail )
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
}

+ (void)deviceDidBecomeBeacon:(BOOL)isBeacon
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    [currentInstallation setObject:[NSNumber numberWithBool:isBeacon] forKey:@"isBeacon"];
    
    [currentInstallation saveInBackground];
}

+ (void)notifyBeaconWithStatus:(BOOL)inside
{
    PFQuery *userQuery = [PFQuery queryWithClassName:kUserClass];
    [userQuery whereKey:kEmailKey equalTo:[BCUserManager currentUserEmail]];
    
    PFQuery *installationQuery = [PFInstallation query];
    [installationQuery whereKey:@"user" matchesQuery:userQuery];
    [installationQuery whereKey:@"isBeacon" equalTo:[NSNumber numberWithBool:YES]];
    
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

+ (void)sendPhotos:(NSArray *)photos withStatus:(BOOL)friendly
{
    NSMutableArray *photoObjects = [[NSMutableArray alloc] init];
    
    int imageCount = 1;
    for( NSString *photoPath in photos )
    {
        NSString *fileName = [NSString stringWithFormat:@"%d.jpg", imageCount];
        PFFile *imageFile = [PFFile fileWithName:fileName contentsAtPath:photoPath];
        
        PFObject *userPhoto = [PFObject objectWithClassName:kUserPhotoClass];
        [userPhoto setObject:imageFile forKey:kPhotoKey];
        
        [photoObjects addObject:userPhoto];
        imageCount++;
    }
    
    PFQuery *userQuery = [PFQuery queryWithClassName:kUserClass];
    [userQuery whereKey:kEmailKey equalTo:[BCUserManager currentUserEmail]];
    
    [userQuery findObjectsInBackgroundWithBlock:^( NSArray *objects, NSError *error )
    {
        PFObject *userObject = [objects lastObject];
        
        PFObject *newPhotoSet = [PFObject objectWithClassName:kPhotoSetClass];
        [newPhotoSet setObject:[photoObjects copy] forKey:@"photos"];
        
        [newPhotoSet setObject:[NSNumber numberWithBool:friendly] forKey:@"friendly"];
        
        [newPhotoSet setObject:userObject forKey:@"user"];
        
        [newPhotoSet saveInBackgroundWithBlock:^( BOOL succeeded, NSError *error )
        {
            if( error )
            {
                NSLog(@"%@", error.localizedDescription);
            }
            if( !succeeded )
            {
                NSLog(@"UPLOADING PHOTOS FAILED");
            }
            else
            {
                for( NSString *filePath in photos )
                {
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                }
            }
        }];
    }];
    
    PFQuery *installationQuery = [PFInstallation query];
    [installationQuery whereKey:@"user" matchesQuery:userQuery];
    [installationQuery whereKey:@"isBeacon" equalTo:[NSNumber numberWithBool:NO]];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:installationQuery];
    
    NSString *message = nil;
    
    if( friendly )
    {
        message = @"Friendly Alert! Motion has been detected!";
    }
    else
    {
        message = @"Intruder Alert! Motion has been detected!";
    }
    
    [push setMessage:message];
    [push sendPushInBackground];
}

+ (void)getAvailablePhotos
{
    PFQuery *userQuery = [PFQuery queryWithClassName:kUserClass];
    [userQuery whereKey:kEmailKey equalTo:[BCUserManager currentUserEmail]];
    
    PFQuery *photoSetsQuery = [PFQuery queryWithClassName:kPhotoSetClass];
    [photoSetsQuery whereKey:@"user" matchesQuery:userQuery];
    
    [photoSetsQuery findObjectsInBackgroundWithBlock:^( NSArray *objects, NSError *error )
    {
        NSLog(@"%@", objects);
        
    }];
}

@end