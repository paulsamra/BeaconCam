//
//  BCAppDelegate.m
//  BeaconCam
//
//  Created by Ryan Khalili on 5/9/14.
//  Copyright (c) 2014 Swipe Development. All rights reserved.
//

#import "BCAppDelegate.h"
#import <Parse/Parse.h>
#import "BCBluetoothManager.h"
#import "BCUserManager.h"

@implementation BCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [BCBluetoothManager sharedManager];
    
    NSDictionary *barAttributes = @{ NSFontAttributeName : [UIFont fontWithName:@"Avenir-Light" size:20] };
    [[UINavigationBar appearance] setTitleTextAttributes:barAttributes];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.636 green:0.589 blue:0.701 alpha:1]];
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    
    NSDictionary *buttonAttributes = @{ NSFontAttributeName : [UIFont fontWithName:@"Avenir-Light" size:18] };
    [[UIBarButtonItem appearance] setTitleTextAttributes:buttonAttributes forState:UIControlStateNormal];
    
    [Parse setApplicationId:@"LBH8ffWLcjD6u1udC4Oog1ZoA8LVHcHNbSzLmjbs" clientKey:@"nlFTQozY9XDWC0bxEQP90X2KCF8ZN2Zt7QMdemwB"];
    
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge |
                                                    UIRemoteNotificationTypeAlert |
                                                    UIRemoteNotificationTypeSound];
    
    [BCUserManager determineUserRegionStatus];
    [BCUserManager deviceDidBecomeBeacon:NO];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [BCUserManager deviceDidBecomeBeacon:NO];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [BCUserManager deviceDidBecomeBeacon:NO];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [BCUserManager deviceDidBecomeBeacon:NO];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"did register");
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"RECEIVED NOTIFICATION: %@", userInfo);
    [BCUserManager handlePush:userInfo];
}

@end
