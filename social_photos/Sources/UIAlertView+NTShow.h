//
//  UIAlertView+NTShow.m
//
//  Created by Nate on 4/15/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (NTShow)

+ (void)showWithTitle:(NSString *)title message:(NSString *)message;
+ (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message cancelTitle:(NSString *)cancelTitle;
+ (void)showAlertWithMessage:(NSString *)message;

@end
