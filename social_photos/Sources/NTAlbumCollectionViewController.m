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

@interface NTAlbumCollectionViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic) NSMutableArray *photos;
@end

@implementation NTAlbumCollectionViewController

static NSString * const reuseIdentifier = @"cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _photos = [NSMutableArray array];
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    [self retrievePhotos];
    
    UIBarButtonItem *uploadButton = [[UIBarButtonItem alloc] initWithTitle:@"UPLOAD" style:UIBarButtonItemStylePlain target:self action:@selector(openPhotos)];
    [self.navigationItem setRightBarButtonItem:uploadButton];
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
    
    // find the lowest res
    id photo = self.photos[indexPath.row];
    
    id selectedImage;
    NSUInteger minHeight = SIZE_MAX;
    for (id image in photo[@"images"]) {
        NSUInteger height = [image[@"height"] integerValue];
        if (height < minHeight ) {
            minHeight = height;
            selectedImage = image;
        }
    }
    
    if( selectedImage ) {
        __block NSString *source = selectedImage[@"source"];
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0) , ^{
            
            NSURL *url= [NSURL URLWithString:source];
            NSData *data = [NSData dataWithContentsOfURL:url];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [imageView setImage:[[UIImage alloc] initWithData:data]];
            });
        });
    }
    
    return cell;
}



#pragma mark <UICollectionViewDelegate>

#pragma mark -
#pragma mark - Other Functions

- (void)retrievePhotos
{
    if(!self.album) return;
    
    __weak typeof(self) weakself = self;
    NSString *urlString = [NSString stringWithFormat:@"/%@?fields=photos,id,name", self.album[@"id"]];
    [FBRequestConnection startWithGraphPath:urlString completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NTLogConnection(connection, result, error);
        
        // set data
        weakself.photos = result[@"photos"][@"data"];
        
        // reload table view
        [weakself.collectionView reloadData];
    }];
}

- (void)openPhotos
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [picker setDelegate:self];
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NTLogTitleMessage(@"photo", info);
}

@end
