//
//  NTNavigationBar.m
//  social_photos
//
//  Created by Nate on 11/27/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTNavigationBar.h"

@implementation NTNavigationBar

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        // remove background
        self.shadowImage = [UIImage new];
        [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.translucent = YES;
    } return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
