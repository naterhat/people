//
//  NTTableView.m
//  social_photos
//
//  Created by Nate on 11/27/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTTableView.h"

@implementation NTTableView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ( self = [super initWithCoder:aDecoder] ) {
        // change background view
        UIColor *patternColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_wood_texture.jpg"]];
        UIView *view = [[UIView alloc] initWithFrame:self.bounds];
        [view setBackgroundColor:patternColor];
        [self setBackgroundView:view];
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
