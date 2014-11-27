//
//  NTPhotosCollectionViewController.m
//  social_photos
//
//  Created by Nate on 11/25/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTPhotosCollectionViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <FacebookSDK/FacebookSDK.h>
#import "NTGlobal.h"
#import "UIAlertView+NTShow.h"
#import "UIActivityIndicatorView+NTShow.h"
#import "NTSocialInterface.h"
#import <Photos/Photos.h>

static CGFloat const kDeselectValue = 0.4f;
static CGFloat const kSelectValue = 1.0f;

@interface NTPhotosCollectionViewController ()<UIAlertViewDelegate>
@property (nonatomic) NSMutableArray *photos;
@property (nonatomic) NSMutableArray *photoThumbnails;
@property (nonatomic) UIBarButtonItem *sendButton;
@property (nonatomic) NSInteger uploadRequestCount;
@property (nonatomic) NSInteger uploadRequestErrorCount;
@end

@implementation NTPhotosCollectionViewController

static NSString * const reuseIdentifier = @"cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _photos = [NSMutableArray array];
    _photoThumbnails = [NSMutableArray array];
    
    [self setTitle:@"PHOTOS"];
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"SEND" style:UIBarButtonItemStylePlain target:self action:@selector(send)];
    [self.navigationItem setRightBarButtonItem:sendButton];
    _sendButton = sendButton;
    
    [self.collectionView setAllowsMultipleSelection:YES];
    
    // Do any additional setup after loading the view.
    [self retrievePhotosFromAlbum];
}

- (void)retrievePhotosFromAlbumOfIOS7
{
    if( [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied ) {
        NSString *message = @"Please go to Settings and authorize Social Photos to gain access to photos.";
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:message
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }
    
    // Source been copied and modified from the version of this link
    // http://stackoverflow.com/questions/9705478/get-list-of-all-photo-albums-and-thumbnails-for-each-album
    
    __weak typeof(self) weakself = self;
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        // Within the group enumeration block, filter to enumerate just photos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        // Chooses the photo at the last index
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
            // The end of the enumeration is signaled by asset == nil.
            if (alAsset) {
                
                
                NSString *type = [alAsset valueForProperty:ALAssetPropertyType];
                
                if([type isEqualToString:@"ALAssetTypePhoto"]) {
                    
                    ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                    
                    // get the images from assets
                    UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
                    UIImage *latestPhotoThumbnail =  [UIImage imageWithCGImage:[alAsset thumbnail]];
                    
                    // save images and thumbnails to array to use later.
                    [weakself.photos addObject:latestPhoto];
                    [weakself.photoThumbnails addObject:latestPhotoThumbnail];
                }
            }
        }];
        
        [weakself.collectionView reloadData];
    } failureBlock: ^(NSError *error) {
        // Typically you should handle an error more gracefully than this.
        NSLog(@"No groups");
    }];
}

- (void)retrievePhotosFromAlbumOfIOS8
{
    
    if( [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied ) {
        NSString *message = @"Please go to Settings and authorize Social Photos to gain access to photos.";
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:message
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    [option setSynchronous:YES];
    
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil];
    [result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NTLogTitleMessage(@"photo", obj);
        
        [[PHImageManager defaultManager] requestImageForAsset:obj targetSize:CGSizeMake([obj pixelWidth], [obj pixelHeight]) contentMode:PHImageContentModeDefault options:option resultHandler:^(UIImage *result, NSDictionary *info) {
            NSLog(@"info: %@ / result: %@", info, result);
            [self.photos addObject:result];
        }];
    }];
    
    NSLog(@"get thumbnails");
    
    [result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NTLogTitleMessage(@"photo", obj);
        [[PHImageManager defaultManager] requestImageForAsset:obj targetSize:CGSizeMake(150, 150) contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage *result, NSDictionary *info) {
            NSLog(@"info: %@ / result: %@", info, result);
            [self.photoThumbnails addObject:result];
        }];
        
    }];
    
    
    PH
    
    
    
    [[self collectionView] reloadData];
    
}

- (void)retrievePhotosFromAlbum
{
    Class PHPhotoLibraryClass = NSClassFromString(@"PHPhotoLibrary");
    if (  PHPhotoLibraryClass ) {
        [self retrievePhotosFromAlbumOfIOS8];
    } else {
        [self retrievePhotosFromAlbumOfIOS7];
    }
}

- (void)send
{
    if( self.collectionView.indexPathsForSelectedItems.count == 0 ) {
        [UIAlertView showAlertWithTitle:@"Error" andMessage:@"Need to select at least 1 photo." cancelTitle:nil];
        return;
    }
    
    // get selected photos
    NSMutableArray *selectedImages = [NSMutableArray array];
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
        [selectedImages addObject: self.photos[indexPath.row]];
    }
    
    // check if any photos to upload
    if ( ! selectedImages.count ) {
        NSLog(@"Must select at least 1 image");
        return;
    }
    
    // show indicator
    [UIActivityIndicatorView showIndicator];
    
    __weak typeof(self) weakself = self;
    [[NTSocialInterface sharedInstance] uploadImages:selectedImages toAlbum:self.album handler:^(BOOL sucess, NSError *error) {
        // hide indicator
        [UIActivityIndicatorView hideIndicator];
        
        if ( error ) {
            // display error
            [UIAlertView showAlertWithTitle:@"Error" andMessage:error.localizedDescription cancelTitle:nil];
        } else {
            [UIAlertView showAlertWithTitle:@"Success" andMessage:@"Next step, need to approve the upload photos over facebook.com." cancelTitle:nil];
            
            // no error, go back to album view
            [weakself.navigationController popViewControllerAnimated:YES];
        }
    } forInterfaceType:NTSocialInterfaceTypeFacebook];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    
    // Configure the cell
    UIImageView *imageView = (id)[cell viewWithTag:1];
    if ( ! imageView ) {
        imageView =[[UIImageView alloc] initWithFrame:cell.bounds];
        [imageView setTag:1];
        [cell.contentView addSubview:imageView];
    }
    
    // set image
    UIImage *image = self.photoThumbnails[indexPath.row];
    [imageView setImage:image];
    
    // set the highlight color
    [imageView setAlpha: cell.selected ? kSelectValue : kDeselectValue];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIImageView *imageView = (id)[[collectionView cellForItemAtIndexPath:indexPath] viewWithTag:1];
    if ( !imageView ) return;
    
    [imageView setAlpha:kDeselectValue];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // validate to select at most 4
    if( collectionView.indexPathsForSelectedItems.count > 4 ) {
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        [UIAlertView showAlertWithTitle:@"Error" andMessage:@"Can only post at most 4 photos." cancelTitle:nil];
        return;
    }
    
    // get image view and select it
    UIImageView *imageView = (id)[[collectionView cellForItemAtIndexPath:indexPath] viewWithTag:1];
    if ( !imageView ) return;
    
    [imageView setAlpha:kSelectValue];
}

#pragma mark -
#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // denied photos permission should be the only one to call this method
    [self.navigationController popViewControllerAnimated:YES];
}


@end
