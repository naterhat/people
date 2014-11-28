//
//  NTPhotoManager.h
//  social_photos
//
//  Created by Nate on 11/27/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NTPhotoManager : NSObject
+ (instancetype)sharedInstance;
@end

@protocol NTPhotoManagerInstance <NSObject>

- (NSUInteger)photoCount;
- (void)authorizing:(void(^)(BOOL success))handler;
- (BOOL)authorized;
- (void)loadAssetsWithCompletion:(void(^)())handler;

/**
 *  Used to retieve asset. This is used because to be sync with Photo Library.
 */
- (id)photoAssetAtIndex:(NSUInteger)index;

/**
 *  Sync call to retrieve all images
 */
- (NSArray *)imagesForPhotoAssets:(NSArray *)photoAssets;

/**
 *  This method either retrieves image sync (blocking thread) Or by async and then calls handler when done.
 */
- (UIImage *)imageForPhotoAsset:(id)asset sync:(BOOL)sync thumbnailed:(BOOL)thumbnailed asyncHandler:(void (^)(UIImage *image))handler;
@end

@interface NTPhotoManagerALAsset : NTPhotoManager <NTPhotoManagerInstance>

@end

@interface NTPhotoManagerPHAsset : NTPhotoManager <NTPhotoManagerInstance>

@end


