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
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "BCStyleKit.h"
#import "BCPhotoBrowser.h"

@interface BCPhotosVC() <UIActionSheetDelegate, MWPhotoBrowserDelegate>

@property (strong, nonatomic) NSDateFormatter       *dateFormatter;
@property (strong, nonatomic) NSMutableDictionary   *images;
@property (strong, nonatomic) NSArray               *imagesToBrowse;
@property (strong, nonatomic) UIRefreshControl      *refreshControl;

@property (nonatomic) int sectionToBrowse;

@end


@implementation BCPhotosVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadPhotos) name:kPhotosLoaded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable) name:kPhotosUpdated object:nil];
    
    self.images = [[NSMutableDictionary alloc] init];
    
    [self.collectionView addSubview:self.refreshControl];
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

- (void)refreshTable
{
    [self.collectionView reloadData];
    
    if( [self.refreshControl isRefreshing] )
    {
        [self.refreshControl endRefreshing];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [[BCPhotosManager savedPhotoSets] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSDictionary *photoSet = [[BCPhotosManager savedPhotoSets] objectAtIndex:section];
    
    return [[photoSet objectForKey:kPhotoFiles] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
    
    NSDictionary *photoSet = [[BCPhotosManager savedPhotoSets] objectAtIndex:indexPath.section];
    
    NSString *photoURL = [[photoSet objectForKey:kPhotoFiles] objectAtIndex:indexPath.row];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    
    [imageView setImageWithURL:[NSURL URLWithString:photoURL] placeholderImage:nil usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
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
    
    return headerView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.sectionToBrowse = indexPath.section;
    
    NSDictionary *photoSet = [[BCPhotosManager savedPhotoSets] objectAtIndex:indexPath.section];
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    
    for( int i = 0; i < [[photoSet objectForKey:kPhotoFiles] count]; i++ )
    {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:path];
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
        
        MWPhoto *photo = [MWPhoto photoWithImage:imageView.image];
        [images addObject:photo];
    }
    
    self.imagesToBrowse = images;
    
	BCPhotoBrowser *browser = [[BCPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton     = NO;
    browser.displayNavArrows        = YES;
    browser.displaySelectionButtons = NO;
    browser.alwaysShowControls      = YES;
    browser.zoomPhotosToFill        = YES;
    browser.enableGrid              = NO;
    browser.enableSwipeToDismiss    = YES;
    [browser setCurrentPhotoIndex:indexPath.row];
    
    [self.navigationController pushViewController:browser animated:YES];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    NSDictionary *photoSet = [[BCPhotosManager savedPhotoSets] objectAtIndex:self.sectionToBrowse];
    
    return [[photoSet objectForKey:kPhotoFiles] count];
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if( index < [self.imagesToBrowse count] )
    {
        return [self.imagesToBrowse objectAtIndex:index];
    }
    
    return nil;
}

- (void)refreshPhotos
{
    [BCUserManager getAvailablePhotos];
}

- (UIRefreshControl *)refreshControl
{
    if( !_refreshControl )
    {
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(refreshPhotos) forControlEvents:UIControlEventValueChanged];
    }
    
    return _refreshControl;
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