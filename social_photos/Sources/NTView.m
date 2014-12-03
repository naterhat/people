//
//  NTView.m
//  social_photos
//
//  Created by Nate on 12/2/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTView.h"

@implementation NTView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ( self = [super initWithCoder:aDecoder] ) {
        // change background view
        UIColor *patternColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_wood_texture.jpg"]];
        [self setBackgroundColor:patternColor];
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
