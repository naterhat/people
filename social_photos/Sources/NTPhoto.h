//
//  NTPhoto.h
//  social_photos
//
//  Created by Nate on 11/26/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTPhoto : NSObject
@property (nonatomic) NSArray *images;

@end

@interface NTPhoto (Facebook)
- (instancetype)initWithFacebookObject:(id)obj;
- (id)smallestImage;
@end