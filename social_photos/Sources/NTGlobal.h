//
//  NTGlobal.h
//  social_photos
//
//  Created by Nate on 11/25/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef NTGlobal_h
#define NTGlobal_h

/**
 *  Log
 */
#define NTLogConnection(connection, result, error) NSLog(@"\n=========================\n\n\
%@\n-------------------------\n\
%@\n=========================\n%@", connection, result, error)

#define NTLogTitleMessage(title, message) NSLog(@"\n%@\n======================\n%@", title, message)


/**
 *  iOS version check
 */
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


/**
 *  Color
 */
#define NTGlobalTextColor [UIColor colorWithRed:0.224f green:0.106f blue:0.055f alpha:1.0f]

#endif