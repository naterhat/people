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

@interface NTAlbumCollectionViewController ()<UIAlertViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic) NSMutableArray *photos;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end

@implementation NTAlbumCollectionViewController

static NSString * const reuseIdentifier = @"cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _photos = [NSMutableArray array];
    
    [self setTitle:self.album.name];
    
//    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
//        [self.collectionView registerClass:[NTImageCell class] forCellWithReuseIdentifier:reuseIdentifier];
//    }
    
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
    __block NTImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NTPhoto *photo = self.photos[indexPath.row];
    
    // retrieve the smallest image in background
    [photo retrieveSmallestImageWithHandler:^(UIImage *image) {
        [cell.imageView setImage:image];
    }];
    
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
