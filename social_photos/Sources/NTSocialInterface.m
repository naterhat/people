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

- (void)retrieveUserForInterfaceType:(NSString *)interfaceType retrieveUserHanlder:(NTSocialInterfaceRetrieveUser)handler
{
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NTLogConnection(connection, result, error);
        
        // check if any errors
        if (error)  {
            handler(nil, error);
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

@end
