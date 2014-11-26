//
//  NTUser.h
//  social_photos
//
//  Created by Nate on 11/25/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTUser : NSObject<NSCoding>

+ (instancetype)currentUser;

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *identifier;
@property (nonatomic) NSMutableArray *albums;

- (void)clear;

@end
