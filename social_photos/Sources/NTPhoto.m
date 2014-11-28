//
//  NTPhoto.m
//  social_photos
//
//  Created by Nate on 11/26/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTPhoto.h"

@implementation NTPhoto

@end

// ===============================

@implementation  NTPhoto (Facebook)

- (instancetype)initWithFacebookObject:(id)obj
{
    if(self = [super init] ) {
        _images = obj[@"images"];
    } return self;
}

- (id)smallestImage
{
    // find the smallest image
    id smallestImage;
    NSUInteger minHeight = SIZE_MAX;
    for (id image in self.images) {
        NSUInteger height = [image[@"height"] integerValue];
        // check height
        if (height < minHeight ) {
            minHeight = height;
            smallestImage = image;
        }
    }
    
    return smallestImage;
}

@end
