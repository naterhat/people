//
//  NTCameraCollectionViewController.m
//  social_photos
//
//  Created by Nate on 11/27/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTCameraCollectionViewController.h"
#import "NTImageCell.h"
#import "NTGlobal.h"
#import "UIAlertView+NTShow.h"
#import "UIActivityIndicatorView+NTShow.h"
#import "NTSocialInterface.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+NTExtra.h"

static CGFloat const kDeselectValue = 0.4f;
static CGFloat const kSelectValue = 1.0f;

@interface NTCameraCollectionViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>
@property (nonatomic) NSMutableArray *photos;
@property (nonatomic) UIBarButtonItem *sendButton;
@property (nonatomic) BOOL viewDidAppeared;
@end

@implementation NTCameraCollectionViewController

static NSString * const reuseIdentifier = @"cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"CAMERA"];
    
    _photos = [NSMutableArray array];
    
    // add 1 image to the end
    UIImage *addImage = [UIImage imageNamed:@"plus"];
    UIImage *newAddImage = [UIImage blendImage:addImage withColor:NTGlobalTextColor];
    [_photos addObject:newAddImage];
    
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"SEND"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(send)];
    [self.navigationItem setRightBarButtonItem:sendButton];
    _sendButton = sendButton;
    
    [self.collectionView setAllowsMultipleSelection:YES];
    
    // reload
    [self collectionView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.viewDidAppeared) {
        self.viewDidAppeared = YES;
        [self determineCameraAccess];
    }
}


- (void)determineCameraAccess
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        [self openCamera];
    } else if(authStatus == AVAuthorizationStatusDenied){
        // denied. Go back to previous screen.
        NSString *message = @"Please go to Settings and authorize People to gain access to camera.";
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:message
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    } else if(authStatus == AVAuthorizationStatusRestricted){
        // restricted, normally won't happen. Show dialog and then go back to previous screen.
        NSString *message = @"Camera is restricted. Can't use this feature at this time.";
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:message
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        // check the user response to the camera access.
        __weak typeof(self) weakself = self;
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){
                NSLog(@"Granted access to %@", AVMediaTypeVideo);
            } else {
                NSLog(@"Not granted access to %@", AVMediaTypeVideo);
            }
            
            [weakself determineCameraAccess];
        }];
    } else {
        // impossible, unknown authorization status
    }
}


- (void)openCamera
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [imagePicker setAllowsEditing:YES];
    [imagePicker setDelegate:self];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)addImage:(UIImage *)image
{
    [self.photos insertObject:image atIndex:1];
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.collectionView insertItemsAtIndexPaths:@[ newIndexPath ] ];
}

- (void)send
{
    // validate if selected at least 1 photo.
    if( self.collectionView.indexPathsForSelectedItems.count == 0 ) {
        [UIAlertView showAlertWithTitle:@"Error" andMessage:@"Need to select at least 1 photo." cancelTitle:nil];
        return;
    }
    
    NSMutableArray *selectedImages = [NSMutableArray array];
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
        [selectedImages addObject:self.photos[indexPath.row]];
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

#pragma mark -
#pragma mark - UIImagePickerController Delegaet & UINavigationController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[@"UIImagePickerControllerEditedImage"];
    if (image) {
        [self addImage:image];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NTImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // set image
    [cell.imageView setImage:self.photos[indexPath.row]];

    // set the highlight color
    if (indexPath.row == 0) {
        // don't highlight the first cell
        [cell.imageView setAlpha: 1.0]; // no opacity.
    } else {
        [cell.imageView setAlpha: cell.selected ? kSelectValue : kDeselectValue];
    }
    
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
    // check if click last image. open camera.
    if (indexPath.row == 0) {
        NSLog(@"click last image");
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        [self openCamera];
        return;
    }
    
    // validate to select at most 4
    if (collectionView.indexPathsForSelectedItems.count > 4) {
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
