//
//  NTCollectionView.m
//  social_photos
//
//  Created by Nate on 11/27/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTCollectionView.h"

@implementation NTCollectionView

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

@end
