//
//  UIAlertView+NTShow.m
//
//  Created by Nate on 4/15/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "UIAlertView+NTShow.h"

@implementation UIAlertView (NTShow)

+ (void)showWithTitle:(NSString *)title message:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

+ (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message cancelTitle:(NSString *)cancelTitle
{
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:(cancelTitle?cancelTitle:@"OK") otherButtonTitles:nil] show];
}

+ (void)showAlertWithMessage:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

@end
