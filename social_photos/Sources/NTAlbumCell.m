//
//  NTAlbumCell.m
//  social_photos
//
//  Created by Nate on 11/27/14.
//  Copyright (c) 2014 ifcantel. All rights reserved.
//

#import "NTAlbumCell.h"
#import "NTGlobal.h"
#import "UIImage+NTExtra.h"

@implementation NTAlbumCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        // get blended image
        UIImage *arrowImage = [UIImage imageNamed:@"right_arrow"];
        UIImage *blendImage = [UIImage blendImage:arrowImage withColor:NTGlobalTextColor];
        
        // set accessory view
        UIImageView *accessoryView = [[UIImageView alloc] initWithImage:blendImage];
        [accessoryView setFrame:CGRectMake(0, 0, 20, 20)];
        [accessoryView setContentMode:UIViewContentModeScaleAspectFit];
        [self setAccessoryView:accessoryView];
    } return self;
}

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    NSLog(@"selected");

    // Configure the view for the selected state
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
//    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        [self setBackgroundColor:[UIColor blueColor]];
    } else {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    
    NSLog(@"highlight animated");
}


@end
