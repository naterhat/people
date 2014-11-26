//
//  NTUser.h
//  social_photos
//
//  Created by Nate on 11/25/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTUser : NSObject<NSCoding>
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *identifier;
@property (nonatomic) NSMutableArray *albums;

/**
 *  Get shared instance of current user
 */
+ (instancetype)currentUser;

/**
 *  Clear all data
 */

- (void)clear;
/**
 *  Clear data and save
 */
- (void)clearAndSave;

- (BOOL)loaded;

@end
