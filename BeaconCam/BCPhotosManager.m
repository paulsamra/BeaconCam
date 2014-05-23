//
//  BCPhotosManager.m
//  BeaconCam
//
//  Created by Ryan Khalili on 5/23/14.
//  Copyright (c) 2014 Swipe Development. All rights reserved.
//

#import "BCPhotosManager.h"

@implementation BCPhotosManager

+ (BCPhotosManager *)sharedManager
{
    static BCPhotosManager *manager = nil;
    
    static dispatch_once_t singleton;
    
    dispatch_once(&singleton, ^{
        manager = [[BCPhotosManager alloc] init];
    });
    
    return manager;
}



@end
