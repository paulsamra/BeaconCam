//
//  BCUserManager.h
//  BeaconCam
//
//  Created by Ryan Khalili on 5/13/14.
//  Copyright (c) 2014 Swipe Development. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPhotosUpdated @"photos_updated"

@interface BCUserManager : NSObject

+ (NSString *)currentUserEmail;
+ (void)setUserEmail:(NSString *)email;

+ (void)determineUserRegionStatus;

+ (void)deviceDidBecomeBeacon:(BOOL)isBeacon;
+ (void)notifyBeaconWithStatus:(BOOL)inside;

+ (void)setShouldAlwaysTakePictureSetting:(BOOL)setting;
+ (BOOL)shouldAlwaysTakePicture;

+ (void)handlePush:(NSString *)message;

+ (void)sendPhotos:(NSArray *)photos withStatus:(BOOL)friendly;
+ (void)getAvailablePhotos;

@end