//
//  NTUser.m
//  social_photos
//
//  Created by Nate on 11/25/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTUser.h"

static NSString *const kNameKey = @"name";
static NSString *const kIdentifierKey = @"identifier";
static NSString *const kAlbumsKey = @"albums";

@implementation NTUser

+ (instancetype)currentUser
{
    static NTUser *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NTUser alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    if ( self = [super init] ) {
        _name = @"";
        _identifier = @"";
        _albums = [NSMutableArray array];
    } return self;
}

- (void)clear
{
    self.name = @"";
    self.identifier = @"";
    self.albums = [NSMutableArray array];
}

- (void)clearAndSave
{
    [self clear];
    
    // save
    // . . .
    // didn't got around doing this.
}

- (BOOL)loaded
{
    if ( !self.identifier || self.identifier.length == 0 ) {
        return NO;
    }
    
    return YES;
}

#pragma mark -
#pragma mark - NSCoding Protocol

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init]) {
        _name = [aDecoder decodeObjectForKey:kNameKey];
        _identifier = [aDecoder decodeObjectForKey:kIdentifierKey];
        
        // first check if exist. if doesn't, assign a new array before adding to the mutable array
        id albums = [aDecoder decodeObjectForKey:kAlbumsKey];
        if( !albums ) albums = @[];
    } return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:kNameKey];
    [aCoder encodeObject:self.identifier forKey:kIdentifierKey];
}

@end

// ===============================

@implementation  NTUser (Facebook)

- (instancetype)initWithFacebookObject:(id)obj
{
    if(self = [super init] ) {
        _name = obj[@"first_name"];
        _identifier = obj[@"id"];
    } return self;
}

@end