//
//  NTAlbum.m
//  social_photos
//
//  Created by Nate on 11/26/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTAlbum.h"

@implementation NTAlbum

@end

// ===============================

@implementation  NTAlbum (Facebook)

- (instancetype)initWithFacebookObject:(id)obj
{
    if(self = [super init] ) {
        _name = obj[@"name"];
        _identifier = obj[@"id"];
    } return self;
}

@end
