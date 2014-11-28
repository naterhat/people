//
//  UIActivityIndicatorView+NTShow.m
//
//  Created by Nate on 11/26/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "UIActivityIndicatorView+NTShow.h"

@implementation UIActivityIndicatorView (NTShow)

+ (void)showIndicator
{
    UIView *rootView = [self rootView];
    if( [self activityIndicatorViewFromView:rootView] ) return;
    
    UIActivityIndicatorView *activity =  [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activity setBackgroundColor:[UIColor colorWithWhite:0 alpha:.8f]];
    [activity setUserInteractionEnabled:YES];
    [activity setHidesWhenStopped:YES];
    [activity startAnimating];
    [activity setFrame:rootView.bounds];
    
    [rootView addSubview:activity];
    
}

+ (void)hideIndicator
{
    UIActivityIndicatorView *activity = [self activityIndicatorViewFromView:[self rootView] ];
    
    if( activity ) {
        [activity removeFromSuperview];
    }
}

+ (UIActivityIndicatorView *)activityIndicatorViewFromView:(UIView *)view
{
    for (id subbiew in view.subviews) {
        if ( [subbiew isKindOfClass:[UIActivityIndicatorView class]] ) {
            return subbiew;
        }
    }
    
    return nil;
}

+ (UIView *)rootView
{
    return [[[[[UIApplication sharedApplication] windows] objectAtIndex:0] rootViewController] view];
}

@end
