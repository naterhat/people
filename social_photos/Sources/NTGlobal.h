//
//  NTGlobal.h
//  social_photos
//
//  Created by Nate on 11/25/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import <Foundation/Foundation.h>


#define NTLogConnection(connection, result, error) NSLog(@"\n=========================\n\n\
%@\n-------------------------\n\
%@\n=========================\n%@", connection, result, error)

#define NTLogTitleMessage(title, message) NSLog(@"\n%@\n======================\n%@", title, message)