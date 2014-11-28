//
//  NTAlbumCollectionViewController.m
//  social_photos
//
//  Created by Nate on 11/25/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTAlbumCollectionViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "NTUser.h"
#import "NTGlobal.h"
#import "NTPhotosCollectionViewController.h"
#import "NTSocialInterface.h"
#import "UIAlertView+NTShow.h"
#import "NTImageCell.h"

@interface NTAlbumCollectionViewController ()<UIAlertViewDelegate>
@property (nonatomic) NSMutableArray *photos;
@end

@implementation NTAlbumCollectionViewController

static NSString * const reuseIdentifier = @"cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _photos = [NSMutableArray array];
    
    [self setTitle:self.album.name];
    
    // add upload button to the right of the navigation bar
    UIBarButtonItem *uploadButton = [[UIBarButtonItem alloc] initWithTitle:@"UPLOAD"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(openPhotos)];
    [self.navigationItem setRightBarButtonItem:uploadButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self retrievePhotos];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id vc = (id)segue.destinationViewController;
    [vc setAlbum:self.album];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NTImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // retrieve the smallest image
    NTPhoto *photo = self.photos[indexPath.row];
    id smallestImage = [photo smallestImage];
    
    if ( !smallestImage ) return cell;
    
    // display the smallest image. Didn't have chance to conver the image dictioanry to NSObject.
    // retrieve image from web by async
    __block NSString *source = smallestImage[@"source"];
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0) , ^{
        
        // get image data
        NSURL *url= [NSURL URLWithString:source];
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        // get back to main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // load image to image view.
            [cell.imageView setImage:[[UIImage alloc] initWithData:data]];
        });
    });
    
    return cell;
}

#pragma mark -
#pragma mark - Other Functions

- (void)retrievePhotos
{
    __weak typeof(self) weakself = self;
    
    [[NTSocialInterface sharedInstance] retrievePhotosWithHandler:^(NSArray *photos, NSError *error) {
        if (error) {
            [UIAlertView showAlertWithTitle:@"Error" andMessage:error.localizedDescription cancelTitle:nil];
        } else {
            BOOL updated = weakself.photos.count != photos.count;
            
            if (updated) {
                // set data
                weakself.photos = [NSMutableArray arrayWithArray:photos];
                
                // reload collection view
                [weakself.collectionView reloadData];
            }
        }
    } fromAlbum:self.album forInterfaceType:NTSocialInterfaceTypeFacebook];
}

- (void)openPhotos
{
    NSString *message = @"Select method to upload photos:";
    [[[UIAlertView alloc] initWithTitle:nil
                                message:message
                               delegate:self
                      cancelButtonTitle:@"Cancel"
                      otherButtonTitles:@"Camera", @"Photo Library", nil] show];
}


#pragma mark -
#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // open camera
        [self performSegueWithIdentifier:@"camera" sender:self];
    } else if (buttonIndex == 2) {
        // open photos
        [self performSegueWithIdentifier:@"photos" sender:self];
    }
}

@end
