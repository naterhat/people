//
//  NTAlbum.h
//  social_photos
//
//  Created by Nate on 11/26/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NTPhoto;

@interface NTAlbum : NSObject
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *identifier;
@property (nonatomic) NSString *coverPhotoID;
@property (nonatomic) NTPhoto *photo;

@end


@interface NTAlbum (Facebook)
- (instancetype)initWithFacebookObject:(id)obj;
@end
