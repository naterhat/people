//
//  NTImageCell.m
//  social_photos
//
//  Created by Nate on 11/27/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTImageCell.h"

@implementation NTImageCell

- (void)awakeFromNib
{
    [self.imageView.layer setCornerRadius:8];
    [self.imageView.layer setMasksToBounds:NO];
    [self.imageView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.imageView.layer setShadowOpacity:1];
    [self.imageView.layer setShadowRadius:2];
    [self.imageView.layer setShadowOffset:CGSizeMake(2, 2)];
}

@end
