//
//  NTSocialInterface.h
//  social_photos
//
//  Created by Nate on 11/26/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTUser.h"
#import "NTAlbum.h"
#import "NTPhoto.h"

extern NSString *const NTSocialInterfaceTypeFacebook;

typedef void(^NTSocialInterfaceRetrieveUser)(NTUser *user, NSError *error);
typedef void(^NTSocialInterfaceRetrieveAlbums)(NSArray *albums, NSError *error);
typedef void(^NTSocialInterfaceRetrievePhotos)(NSArray *photos, NSError *error);
typedef void(^NTSocialInterfaceRequestHandler)(BOOL success, NSError *error);

@interface NTSocialInterface : NSObject
@property (nonatomic) NSInteger uploadRequestCount;
@property (nonatomic) NSInteger uploadRequestErrorCount;

+ (instancetype)sharedInstance;
- (void)logoutFromInterfaceType:(NSString *)interfaceType;
- (void)retrieveUserWithHandler:(NTSocialInterfaceRetrieveUser)handler forInterfaceType:(NSString *)interfaceType;
- (void)retrieveAlbumsWithHandler:(NTSocialInterfaceRetrieveAlbums)handler fromUser:(NTUser *)user forInterfaceType:(NSString *)interfaceType;
- (void)retrievePhotosWithHandler:(NTSocialInterfaceRetrievePhotos)handler fromAlbum:(NTAlbum *)album forInterfaceType:(NSString *)interfaceType;
- (void)uploadImages:(NSArray *)images toAlbum:(NTAlbum *)album handler:(NTSocialInterfaceRequestHandler)handler forInterfaceType:(NSString *)interfaceType;
- (void)createNewAlbumWithName:(NSString *)albumName forUser:(NTUser *)user ofInterfaceType:(NSString *)interfaceType handler:(NTSocialInterfaceRequestHandler)handler;
@end
