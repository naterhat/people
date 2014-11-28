//
//  NTPhotoManager.m
//  social_photos
//
//  Created by Nate on 11/27/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTPhotoManager.h"
#import "NTGlobal.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation NTPhotoManager

+ (instancetype)sharedInstance
{
    static NTPhotoManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

@end

@interface NTPhotoManagerALAsset ()
@property (nonatomic) NSMutableArray *assets;
@property (nonatomic) ALAssetsLibrary *assetLibrary;
@end

@implementation NTPhotoManagerALAsset

- (instancetype)init
{
    if ( self = [super init] ) {
        _assets = [NSMutableArray array];
        _assetLibrary = [[ALAssetsLibrary alloc] init];
    } return self;
}


- (BOOL)authorized
{
    return [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized ;
}

- (BOOL)denied
{
    return [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied;
}

- (NSUInteger)photoCount
{
    return _assets.count;
}

- (id)photoAssetAtIndex:(NSUInteger)index
{
    if(index < _assets.count) {
        return _assets[index];
    }
    return nil;
}

- (void)authorizing:(void (^)(BOOL))handler
{
    if([self denied]) {
        handler(NO);
        return;
    }
    
    if( [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined ) {
        [_assetLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            // success
            if (handler) handler(YES);
            *stop = YES;
        } failureBlock:^(NSError *error) {
            // failure
            handler(NO);
        }];
    }
}

 - (void)retrieveAssetsCompletionHandler:(void(^)())handler
{
    // Source been copied and modified from the version of this link
    // http://stackoverflow.com/questions/9705478/get-list-of-all-photo-albums-and-thumbnails-for-each-album
    
    __weak typeof(self) weakself = self;
    
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [_assetLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        // Within the group enumeration block, filter to enumerate just photos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        __block NSInteger maxCount = [group numberOfAssets];
        
        // Chooses the photo at the last index
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
            // The end of the enumeration is signaled by asset == nil.
            if (alAsset) {
                
                // validate if photo
                NSString *type = [alAsset valueForProperty:ALAssetPropertyType];
                
                if([type isEqualToString:ALAssetTypePhoto]) {
                    
                    [weakself.assets addObject:alAsset];
                }
            }            
            
            // check if last asset. If yes, completion execute.
            if(index == maxCount-1) {
                if (handler) handler();
            }
        }];
        
    } failureBlock: ^(NSError *error) {
        // Typically you should handle an error more gracefully than this.
        NSLog(@"No groups");
    }];
}

- (void)loadAssetsWithCompletion:(void (^)())handler
{
    // clear all assets
    [_assets removeAllObjects];
    
    NSLog(@"PHOTO MANAGE LOAD COMPLETE");
    [self retrieveAssetsCompletionHandler:handler];
}


#pragma mark - Retrieve Images

- (UIImage *)imageForPhotoAsset:(id)asset sync:(BOOL)sync thumbnailed:(BOOL)thumbnailed asyncHandler:(void (^)(UIImage *image))handler
{
    
    // block image holder
    __block UIImage *image = nil;
    
    if (sync) {
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        
        // get the images from asset
        if (thumbnailed) {
            image = [UIImage imageWithCGImage:[asset thumbnail]];
        } else {
            image = [UIImage imageWithCGImage:[representation fullScreenImage]];
        }
    } else {        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            ALAssetRepresentation *representation = [asset defaultRepresentation];
            
            // get the images from asset in background
            if (thumbnailed) {
                image = [UIImage imageWithCGImage:[asset thumbnail]];
            } else {
                image = [UIImage imageWithCGImage:[representation fullScreenImage]];
            }
            
            // get back onto the main thread and return image.
            dispatch_async(dispatch_get_main_queue(), ^{
                if (handler) {
                    handler(image);
                }
            });
        });
    }
    
    // if sync, expected an image. if async, then expected to be nil.
    return image;
}

- (NSArray *)imagesForPhotoAssets:(NSArray *)photoAssets
{
    NSMutableArray *images = [NSMutableArray array];
    for (id photoAsset in photoAssets) {
        [images addObject:[self imageForPhotoAsset:photoAsset sync:YES thumbnailed:NO asyncHandler:nil]];
    }
    
    return images;
}

@end



#import <Photos/Photos.h>

@interface NTPhotoManagerPHAsset ()
@property (nonatomic) PHFetchResult *result;
@end

@implementation NTPhotoManagerPHAsset

- (instancetype)init
{
    if ( self = [super init] ) {
    } return self;
}

- (PHFetchResult *)result
{
    if(!_result) {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        [options setSortDescriptors: @[ [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES] ]];
        _result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
    } return _result;
}

- (BOOL)authorized
{
    return [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized;
}

- (BOOL)denied
{
    return [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied;
}

- (NSUInteger)photoCount
{
    if ( self.result ) {
        return self.result.count;
    } else {
        return 0;
    }
}

- (void)authorizing:(void (^)(BOOL))handler
{
    if([self denied]) {
        handler(NO);
        return;
    }
    
    __weak typeof(self) weakself = self;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        BOOL authorized = status == PHAuthorizationStatusAuthorized;
        
        // get image result if authorized
        if (authorized) {
            [weakself result];
        }
        
        handler(authorized);
        return;
    }];
}

- (id)photoAssetAtIndex:(NSUInteger)index
{
    return [self.result objectAtIndex:index];
}

- (void)loadAssetsWithCompletion:(void (^)())handler
{    
    [self result];
    NSLog(@"PHOTO MANAGE LOAD COMPLETE");
    if (handler) handler();
}

#pragma mark - Retrieve Images

- (UIImage *)imageForPhotoAsset:(id)asset sync:(BOOL)sync thumbnailed:(BOOL)thumbnailed asyncHandler:(void (^)(UIImage *image))handler
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    [options setSynchronous:sync];
    
    // set size of image if thumbnail
    CGSize size;
    if(thumbnailed) {
        size = CGSizeMake(150, 150);
    } else {
        size = CGSizeMake( [asset pixelWidth], [asset pixelHeight] );
    }
    
    // block image holder
    __block UIImage *image = nil;
    
    // execute to retrieve image. Either sync or async.
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        if (sync) {
            image = result;
        } else {
            // choosed async process. Execute handler
            if (handler) handler(result);
        }
    }];
    
    // if sync, expected an image. if async, then expected to be nil.
    return image;
}

- (NSArray *)imagesForPhotoAssets:(NSArray *)photoAssets
{
    NSMutableArray *images = [NSMutableArray array];
    for (id photoAsset in photoAssets) {
        [images addObject:[self imageForPhotoAsset:photoAsset sync:YES thumbnailed:NO asyncHandler:nil]];
    }
    
    return images;
}


@end
