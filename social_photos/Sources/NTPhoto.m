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

- (void)retrieveSmallestImageWithHandler:(void(^)(UIImage *image))handler
{
    id smallestImage = [self smallestImage];
    
    if ( !smallestImage ) {
        NSLog(@"There are no images");
        handler(nil);
        return;
    }
    
    // display the smallest image. Didn't have chance to conver the image dictioanry to NSObject.
    // retrieve image from web by async
    __block NSString *source = smallestImage[@"source"];
    __block UIImage *image = nil;
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0) , ^{
        
        // get image data
        NSURL *url= [NSURL URLWithString:source];
        NSData *data = [NSData dataWithContentsOfURL:url];
        image = [[UIImage alloc] initWithData:data];
        
        // get back to main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // return image
            handler(image);
        });
    });
}

@end
