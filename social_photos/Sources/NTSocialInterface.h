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

extern NSString *const NTSocialInterfaceTypeFacebook;

typedef void(^NTSocialInterfaceRetrieveUser)(NTUser *user, NSError *error);
typedef void(^NTSocialInterfaceRetrieveAlbums)(NSArray *albums, NSError *error);
typedef void(^NTSocialInterfaceRetrievePhotos)(NSArray *photos, NSError *error);
typedef void(^NTSocialInterfaceRequestHandler)(BOOL sucess);

@interface NTSocialInterface : NSObject

+ (instancetype)sharedInstance;
- (void)retrieveUserForInterfaceType:(NSString *)interfaceType retrieveUserHanlder:(NTSocialInterfaceRetrieveUser)handler;
@end
