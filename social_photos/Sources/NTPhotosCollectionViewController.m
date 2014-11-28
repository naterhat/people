//
//  NTPhotosCollectionViewController.m
//  social_photos
//
//  Created by Nate on 11/25/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTPhotosCollectionViewController.h"
#import "NTGlobal.h"
#import "UIAlertView+NTShow.h"
#import "UIActivityIndicatorView+NTShow.h"
#import "NTSocialInterface.h"
#import "NTPhotoManager.h"
#import "NTImageCell.h"

static CGFloat const kDeselectValue = 0.4f;
static CGFloat const kSelectValue = 1.0f;

@interface NTPhotosCollectionViewController ()<UIAlertViewDelegate>
@property (nonatomic) NSMutableArray *selectedAssets;
@property (nonatomic) UIBarButtonItem *sendButton;
@property (nonatomic) NSArray *selectedPhotoAssets;
@property (nonatomic) id<NTPhotoManagerInstance> photoManager;
@end

@implementation NTPhotosCollectionViewController

static NSString * const reuseIdentifier = @"cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _selectedAssets = [NSMutableArray array];
    
    [self setTitle:@"PHOTOS"];
    
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"SEND"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(send)];
    [self.navigationItem setRightBarButtonItem:sendButton];
    _sendButton = sendButton;
    
    [self.collectionView setAllowsMultipleSelection:YES];
    
    // retrieve photo manager
    if ( ! _photoManager ) {
        if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") ) {
            _photoManager = [NTPhotoManagerPHAsset sharedInstance];
        } else {
            _photoManager = [NTPhotoManagerALAsset sharedInstance];
        }
    }
    
    // Do any additional setup after loading the view.
    [self authorizePhotoManager];
}

- (void)authorizePhotoManager
{
    // check if authorized
    __weak typeof(self) weakself = self;
    if( ! [_photoManager authorized] ) {
        [_photoManager authorizing:^(BOOL success) {
            if ( !success ) {
                NTLogTitleMessage(@"PHOTO MANAGER", @"UNSUCCESSFUL");
                
                NSString *message = @"Please go to Settings and authorize People to gain access to photos.";
                [[[UIAlertView alloc] initWithTitle:nil
                                            message:message
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            } else {
                NTLogTitleMessage(@"PHOTO MANAGER", @"SUCCESSFUL");
                // authorize
                [weakself retrievePhotosFromAlbum];
            }
        }];
    } else {
        [self retrievePhotosFromAlbum];
    }
}

- (void)retrievePhotosFromAlbum
{
    __weak typeof(self) weakself = self;
    [_photoManager loadAssetsWithCompletion:^{
        [[weakself collectionView] reloadData];
    }];
}

- (void)send
{
    // validate if selected at least 1 photo.
    if( self.selectedAssets.count == 0 ) {
        [UIAlertView showAlertWithTitle:@"Error" andMessage:@"Need to select at least 1 photo." cancelTitle:nil];
        return;
    }

    // synchronize of retrieving images
    NSArray *selectedImages = [_photoManager imagesForPhotoAssets:self.selectedAssets];
    
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

- (void)addSelectedImage:(UIImage *)image atIndexPath:(NSIndexPath *)indexPath
{
    id asset = [_photoManager photoAssetAtIndex:indexPath.row];
    [self.selectedAssets addObject:asset];
}

- (void)removeSelectedImageAtIndexPath:(NSIndexPath *)indexPath
{
    id asset = [_photoManager photoAssetAtIndex:indexPath.row];
    [self.selectedAssets removeObject:asset];
}

#pragma mark -
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_photoManager photoCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NTImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (_photoManager) {
        // retrieve asset object
        id asset = [_photoManager photoAssetAtIndex:indexPath.row];
        [_photoManager imageForPhotoAsset:asset sync:NO thumbnailed:YES asyncHandler:^(UIImage *image) {
            [cell.imageView setImage:image];
        }];
        
        // check if selected
        BOOL selected = [self.selectedAssets containsObject:asset];
        
        // set the highlight color
        [cell.imageView setAlpha: selected ? kSelectValue : kDeselectValue];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIImageView *imageView = (id)[[collectionView cellForItemAtIndexPath:indexPath] viewWithTag:1];
    if ( !imageView ) return;
    
    [imageView setAlpha:kDeselectValue];
    
    [self removeSelectedImageAtIndexPath:indexPath];
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
    
    [self addSelectedImage:imageView.image atIndexPath:indexPath];
}

#pragma mark -
#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // denied photos permission should be the only one to call this method
    [self.navigationController popViewControllerAnimated:YES];
}


@end
