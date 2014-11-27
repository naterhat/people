//
//  NTSocialInterface.m
//  social_photos
//
//  Created by Nate on 11/26/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTSocialInterface.h"
#import <FacebookSDK/FacebookSDK.h>
#import "NTGlobal.h"

NSString *const NTSocialInterfaceTypeFacebook = @"facebook";

@implementation NTSocialInterface

+ (instancetype)sharedInstance
{
    static NTSocialInterface *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NTSocialInterface alloc] init];
    });
    
    return instance;
}

- (void)retrieveUserWithHandler:(NTSocialInterfaceRetrieveUser)handler forInterfaceType:(NSString *)interfaceType
{
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NTLogConnection(connection, result, error);
        
        // check if any errors
        if (error)  {
            if(handler)  handler(nil, error);
            return;
        }
        
        // retrieve user object
        NTUser *user = [[NTUser alloc] initWithFacebookObject:result];
        
        // if handler, execute handler
        if (handler) {
            handler(user, nil);
        }
    }];
}

- (void)retrieveAlbumsWithHandler:(NTSocialInterfaceRetrieveAlbums)handler fromUser:(NTUser *)user forInterfaceType:(NSString *)interfaceType
{
    // validate user
    if (!user || ![user identifier]) {
        NSLog(@"Error with user ID");
        
        NSError *error = [NSError errorWithDomain:@"com.ifcantel.network" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Error with user ID"}];
        if(handler) handler(nil, error);
        return;
    }
    
    // call to retreive albums
    NSString *urlString = [NSString stringWithFormat:@"/%@/albums", [user identifier]];
    [FBRequestConnection startWithGraphPath:urlString completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NTLogConnection(connection, result, error);
        
        // check if any errors
        if (error)  {
            if(handler) handler(nil, error);
            return;
        }
        
        // retrieve albums and turn into native forms
        NSMutableArray *albums = [NSMutableArray array];
        for (id facebookAlbum in result[@"data"]) {
            NTAlbum *album = [[NTAlbum alloc] initWithFacebookObject:facebookAlbum];
            [albums addObject:album];
        }
        
        // if handler, execute handler
        if (handler) {
            handler(albums, nil);
        }
    }];
}

- (void)retrievePhotosWithHandler:(NTSocialInterfaceRetrievePhotos)handler fromAlbum:(NTAlbum *)album forInterfaceType:(NSString *)interfaceType
{
    // validate album
    if (!album || ![album identifier]) {
        NSLog(@"Error with album ID");
        
        NSError *error = [NSError errorWithDomain:@"com.ifcantel.network" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Error with album ID"}];
        if(handler) handler(nil, error);
        return;
    }
    
    NSString *graphPath = [NSString stringWithFormat:@"/%@?fields=photos,id,name", album.identifier];
    [FBRequestConnection startWithGraphPath:graphPath completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NTLogConnection(connection, result, error);
        
        // check if any errors
        if (error)  {
            handler(nil, error);
            return;
        }
        
        // retrieve albums and turn into native forms
        NSMutableArray *photos = [NSMutableArray array];
        for (id facebookPhoto in result[@"photos"][@"data"]) {
            NTPhoto *photo = [[NTPhoto alloc] initWithFacebookObject:facebookPhoto];
            [photos addObject:photo];
        }
        
        // if handler, execute handler
        if (handler) {
            handler(photos, nil);
        }
    }];
}

- (void)uploadImages:(NSArray *)images toAlbum:(NTAlbum *)album handler:(NTSocialInterfaceRequestHandler)handler forInterfaceType:(NSString *)interfaceType
{
    // validate album
    if (!album || ![album identifier]) {
        NSLog(@"Error with album ID");
        
        NSError *error = [NSError errorWithDomain:@"com.ifcantel.network" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Error with album ID"}];
        if(handler) handler(NO, error);
        return;
    }
    
    // validate image count
    if(images.count == 0) {
        NSError *error = [NSError errorWithDomain:@"com.ifcantel.network" code:2 userInfo:@{NSLocalizedDescriptionKey: @"No images passed"}];
        if(handler) handler(NO, error);
        return;
    }
    
    // initialize iVars
    NSString *graphPath = [NSString stringWithFormat:@"/%@/photos", album.identifier];
    NSString *method = @"POST";
    
    // create array of upload photo requests
    __weak typeof(self) weakself = self;
    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
    for (UIImage *image in images) {
        
        // create and add request
        NSDictionary *params = @{@"source": image};
        FBRequest *request = [FBRequest requestWithGraphPath:graphPath parameters:params HTTPMethod:method];
        [connection addRequest:request completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            NTLogConnection(connection, result, error);
            if( error ) {
                weakself.uploadRequestErrorCount++;
            }
            
            weakself.uploadRequestCount--;
            
            // completed all the request
            if (weakself.uploadRequestCount == 0) {
                
                // reset count
                weakself.uploadRequestCount = 0;
                
                if ( weakself.uploadRequestErrorCount ) {
                    // failure uploading
                    weakself.uploadRequestErrorCount = 0;
                    
                    NSError *error = [NSError errorWithDomain:@"com.ifcantel.network" code:3 userInfo:@{NSLocalizedDescriptionKey: @"There was an error uploading images"}];
                    if( handler ) handler(NO, error);
                    
                    
                } else {
                    // success upload
                    if(handler) handler(YES, nil);
                }
            }
            
        }];
        
        // increase request count
        self.uploadRequestCount++;
    }
    
    [connection start];
}



- (void)logoutFromInterfaceType:(NSString *)interfaceType
{
    [[FBSession activeSession] closeAndClearTokenInformation];
    [[NTUser currentUser] clearAndSave];
}

@end
