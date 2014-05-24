//
//  BCPhotosVC.m
//  BeaconCam
//
//  Created by Ryan Khalili on 5/22/14.
//  Copyright (c) 2014 Swipe Development. All rights reserved.
//

#import "BCPhotosVC.h"
#import "BCUserManager.h"
#import "BCPhotosManager.h"
#import "BCAppDelegate.h"

@interface BCPhotosVC() <UIActionSheetDelegate>

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) UIActionSheet   *actionSheet;

@end

@implementation BCPhotosVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadPhotos) name:kPhotosLoaded object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadPhotos
{
    BCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if( appDelegate.needsPhotoUpdate )
    {
        NSLog(@"needs photo update");
        
        [self.collectionView reloadData];
        
        appDelegate.needsPhotoUpdate = NO;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [[BCPhotosManager savedPhotoSets] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSDictionary *photoSet = [[BCPhotosManager savedPhotoSets] objectAtIndex:section];
    
    return [[photoSet objectForKey:kPhotoIDs] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
    
    UIActivityIndicatorView *busyIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    busyIndicator.center = cell.contentView.center;
    
    [busyIndicator startAnimating];
    
    [cell.contentView addSubview:busyIndicator];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    
    NSDictionary *photoSet = [[BCPhotosManager savedPhotoSets] objectAtIndex:indexPath.section];
    NSString *photoID = [[photoSet objectForKey:kPhotoIDs] objectAtIndex:indexPath.row];
    
    [BCPhotosManager getImageForPhotoID:photoID withBlock:^( UIImage *image, NSError *error )
    {
        imageView.image = image;
        [busyIndicator stopAnimating];
    }];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"photosHeader" forIndexPath:indexPath];
    
    NSDictionary *photoSet = [[BCPhotosManager savedPhotoSets] objectAtIndex:indexPath.section];
    
    UILabel *headerLabel = (UILabel *)[headerView viewWithTag:101];
    NSString *dateString = [self.dateFormatter stringFromDate:[photoSet objectForKey:kPhotoSetDate]];
    
    BOOL friendly = [[photoSet objectForKey:kFriendlyKey] boolValue];
    NSString *friendlyString;
    
    if( friendly )
    {
        friendlyString = @"Friendly";
    }
    else
    {
        friendlyString = @"Intruder";
    }
    
    NSString *labelText = [NSString stringWithFormat:@"%@: %@", friendlyString, dateString];
    
    headerLabel.text = labelText;
    
    UIButton *actionButton = (UIButton *)[headerView viewWithTag:102];
    
    if( indexPath.section == 0 )
    {
        [actionButton addTarget:self action:@selector(takeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        actionButton.hidden = YES;
    }
    
    
    return headerView;
}

- (void)takeAction
{
    [self.actionSheet showInView:self.view];
}

- (UIActionSheet *)actionSheet
{
    if( !_actionSheet )
    {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Action To Take" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Notify Police", nil];
    }
    
    return _actionSheet;
}

- (NSDateFormatter *)dateFormatter
{
    if( !_dateFormatter )
    {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"EEE MM/dd/yyyy hh:mm a"];
    }
    
    return _dateFormatter;
}

@end
