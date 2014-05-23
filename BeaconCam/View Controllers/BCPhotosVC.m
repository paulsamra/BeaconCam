//
//  BCPhotosVC.m
//  BeaconCam
//
//  Created by Ryan Khalili on 5/22/14.
//  Copyright (c) 2014 Swipe Development. All rights reserved.
//

#import "BCPhotosVC.h"
#import "BCUserManager.h"

@interface BCPhotosVC()

@end

@implementation BCPhotosVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [BCUserManager getAvailablePhotos];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
    
    //UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    
    return cell;
}

/*- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}*/

@end
