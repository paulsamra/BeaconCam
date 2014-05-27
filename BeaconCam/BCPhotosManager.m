//
//  BCPhotosManager.m
//  BeaconCam
//
//  Created by Ryan Khalili on 5/23/14.
//  Copyright (c) 2014 Swipe Development. All rights reserved.
//

#import "BCPhotosManager.h"
#import <Parse/Parse.h>

#define kSavedPhotoSets @"savedPhotoSets"
#define kPhotoClass     @"UserPhoto"
#define kObjectIDKey    @"objectId"

@implementation BCPhotosManager

+ (void)savePhotoSetWithID:(NSString *)objectID date:(NSDate *)date files:(NSArray *)files friendly:(BOOL)friendly
{
    NSMutableArray *savedPhotoSets = [[self savedPhotoSets] mutableCopy];
    
    if( !savedPhotoSets )
    {
        savedPhotoSets = [[NSMutableArray alloc] init];
    }
    
    NSNumber *friend = [NSNumber numberWithBool:friendly];
    
    NSDictionary *newPhotoSet = @{ kPhotoSetID : objectID, kPhotoSetDate : date, kFriendlyKey : friend, kPhotoFiles : files };
    
    if( [savedPhotoSets containsObject:newPhotoSet] )
    {
        return;
    }
    
    [savedPhotoSets insertObject:newPhotoSet atIndex:0];
    
    [[NSUserDefaults standardUserDefaults] setObject:savedPhotoSets forKey:kSavedPhotoSets];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)savedPhotoSets
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSavedPhotoSets];
}

+ (void)getImageWithURL:(NSString *)url withBlock:(void(^)( UIImage *image, NSError *error ))completion
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:
    ^(NSURLResponse *response, NSData *data, NSError *error)
    {
        if( error )
        {
            completion( nil, error );
        }
        else
        {
            UIImage *image = [UIImage imageWithData:data];
            completion( image, nil );
        }
    }];
}

+ (void)deleteSavedPhotos
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSavedPhotoSets];
}

@end
