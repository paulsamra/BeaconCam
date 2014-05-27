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
#define kPhotoFiles     @"photoFiles"
#define kPhotosLoaded   @"photosLoaded"

@interface BCPhotosManager : NSObject

+ (void)savePhotoSetWithID:(NSString *)objectID date:(NSDate *)date files:(NSArray *)files friendly:(BOOL)friendly;
+ (NSArray *)savedPhotoSets;
+ (void)getImageWithURL:(NSString *)url withBlock:(void(^)( UIImage *image, NSError *error ))completion;
+ (void)deleteSavedPhotos;

@end