//
//  BCPhotosManager.h
//  BeaconCam
//
//  Created by Ryan Khalili on 5/23/14.
//  Copyright (c) 2014 Swipe Development. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPhotoSetID     @"photoSetID"
#define kPhotoSetDate   @"photoSetDate"
#define kFriendlyKey    @"friendly"
#define kPhotoIDs       @"photoIDs"
#define kPhotosLoaded   @"photosLoaded"

@interface BCPhotosManager : NSObject

+ (void)savePhotoSetWithID:(NSString *)objectID date:(NSDate *)date photoIDs:(NSArray *)photoIDs friendly:(BOOL)friendly;
+ (NSArray *)savedPhotoSets;
+ (void)getImageForPhotoID:(NSString *)photoID withBlock:(void(^)( UIImage *image, NSError *error ))completion;

@end