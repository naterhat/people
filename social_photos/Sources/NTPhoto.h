//
//  NTPhoto.h
//  social_photos
//
//  Created by Nate on 11/26/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NTPhoto : NSObject
@property (nonatomic) NSArray *images;

@end

@interface NTPhoto (Facebook)
- (instancetype)initWithFacebookObject:(id)obj;
- (id)smallestImage;

/**
 *  This function will retrieve the smallest image in the background and return if succeed or not.
 */
- (void)retrieveSmallestImageWithHandler:(void(^)(UIImage *image))handler;
@end